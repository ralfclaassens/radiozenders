import UIKit
import AVFoundation

typealias JSONDictionary = [String: Dictionary<String, Any>]
typealias JSONArray = [JSONDictionary]

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MusicCellProtocol,AVAudioPlayerDelegate {

    @IBOutlet weak var mTrackImage: UIImageView!
    @IBOutlet weak var mDuration: UILabel!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var trackPlayerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerBlur: UIView!
    @IBOutlet weak var playPauseButton:UIButton!

    var categories = [Category]()
    var audioPlayer:AVPlayer?
    var myTimer:Timer!
    var isPlaying = true

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    func initialSetup(){
        customNavbar()
        let nib =  UINib(nibName: "MusicCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        trackPlayerView.isHidden = true
        loadJSON()
        addBlurToPlayer()
    }

    func loadJSON(){
        let urlString = "https://www.radiozenders.fm/station/api/category/category/home"

        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession(configuration: URLSessionConfiguration.default)

        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }

            guard let data = data else { return }

            do {
                let categoryData = try JSONDecoder().decode([Category].self, from: data)
                self.categories = categoryData
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let jsonError {
                print(jsonError)
            }

        }.resume()
    }

    func customNavbar(){
        self.title = "Radiozenders"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "Verdana-Bold", size: 15)!]

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        let searchButton = UIBarButtonItem(image: UIImage(named:"search")!, style: .done, target: self, action: nil)
        let menuButton =  UIBarButtonItem(image: UIImage(named:"menu")!, style: .done, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.rightBarButtonItem = searchButton
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicCell
        if indexPath.row == 0 {
            cell.seeAllButton.isHidden = true
            cell.cellBg.backgroundColor = UIColor.black
            cell.sectionHeader.textColor = UIColor.white
            cell.sectionHeader.text = categories[0].name

        } else {
            cell.seeAllButton.isHidden = false
            cell.sectionHeader.text = categories[indexPath.row].name
            cell.cellBg.backgroundColor = UIColor.white
            cell.sectionHeader.textColor = UIColor.black
        }

        let category = self.categories[indexPath.row]
        cell.setCollectionViewDataSourceDelegate(index: indexPath, stations: category.Stations)
        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TableView:\(indexPath)")
    }

    func addBlurToPlayer(){
        let blur =  UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = playerBlur.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerBlur.addSubview(blurView)
    }

    func didTapSeeAll(cell: MusicCell, indexPath: IndexPath) {

    }

    func didTapOnTrack(cell: MusicCell, indexPath: IndexPath) {
        let k = tableView.indexPath(for: cell)
        playStation(station: self.categories[k!.row].Stations[indexPath.row])
        print("Location:\(k!.row) \(indexPath.row)")
    }

    func playStation(station: Station){
        tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: playerBlur.frame.height, right: 0)
        trackPlayerView.isHidden = false

        let http = station.stream
        var comps = URLComponents(string: http)!
        comps.scheme = "https"
//        let httpsUrl = comps.string!
        let httpsUrl = "https://19113.live.streamtheworld.com/TLPSTR09.mp3"

        self.audioPlayer = AVPlayer(url: URL(string:httpsUrl)!)
        self.audioPlayer?.play()
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        
        let imageBase = "https://www.radiozenders.fm/media/images/stations/"
        mTrackImage.setImageWithUrl(url: NSURL(string:imageBase + station.image)!)
        mName.text = station.name
    }

    @objc func updateProgressBar(){

//        let t1 =  self.audioPlayer?.currentTime()
//        let t2 =  self.audioPlayer?.currentItem?.asset.duration
//
//        let current = CMTimeGetSeconds(t1!)
//        let total = CMTimeGetSeconds(t2!)

//        if Int(current) != Int(total){
//
//            let min = Int(current) / 60
//            let sec =  Int(current) % 60
//            mDuration.text = String(format: "%02d:%02d", min,sec)
//            let percent = (current/total)
//
//            self.progressBar.setProgress(Float(percent), animated: true)
//            print("percent \(percent) - \(current) \(total)")
//        }else{
//            audioPlayer?.pause()
//            audioPlayer = nil
//            myTimer.invalidate()
//            myTimer = nil
//        }
    }

    @IBAction func didTapOnPause(_ sender: Any) {
        if !isPlaying {
            isPlaying = true
            audioPlayer?.play()
            playPauseButton.setImage(UIImage(named:"pause"), for: .normal)

        }else{
            isPlaying = false
            audioPlayer?.pause()
            playPauseButton.setImage(UIImage(named:"play"), for: .normal)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
