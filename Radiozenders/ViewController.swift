import UIKit
import AVFoundation

typealias JSONDictionary = [String: Dictionary<String, Any>]
typealias JSONArray = [JSONDictionary]

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MusicCellProtocol,AVAudioPlayerDelegate {

    @IBOutlet weak var mTrackImage: UIImageView!
    @IBOutlet weak var mTrackName: UILabel!
    @IBOutlet weak var mDuration: UILabel!
    @IBOutlet weak var mArtistName: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var trackPlayerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerBlur: UIView!
    @IBOutlet weak var playPauseButton:UIButton!

//    var category = [Category]()
//    var categories = [Categories]()
//    var stations = [Station]()
    var categories = [Category]()
    var audioPlayer:AVPlayer?
    var myTimer:Timer!
    var sectionHeaders = ["NPO stations","100%NL stations","Sky Radio stations","538 stations","SLAM! stations"]
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
                
//                DispatchQueue.main.async {
                    print(categoryData)
                    self.categories = categoryData
//                    self.collectionView?.reloadData()
                    self.tableView.reloadData()
//                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            
        }.resume()
        
//        do{
//            let jsonData = try Data(contentsOf: path!, options: Data.ReadingOptions.mappedIfSafe)
//            let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as?[String:AnyObject]
//
//            let categoriesList = jsonResult?["categories"] as! NSArray
//
//            for categoryIndex in categoriesList {
//                let categoryFromApi = categoryIndex as? [String:AnyObject]
//                let category = Category()
//
//                category.name = categoryFromApi?["name"] as? String
//
//                let stationList = categoryFromApi?["stations"] as! NSArray
//
//                for stationIndex in stationList{
//                    let stationFromApi = stationIndex as? [String:AnyObject]
//                    let station = Station()
//                    station.id = stationFromApi?["id"] as? String
//                    station.name = stationFromApi?["name"] as? String
//                    station.stream = stationFromApi?["stream_url"] as? String
//                    station.image = stationFromApi?["image_url"] as? String
//                    self.stations.append(station)
//                }
//
//                category.stations = self.stations
//
//                self.category.append(category)
//            }
//
//            self.tableView.reloadData()
//
//        }catch{
//            print(error.localizedDescription)
//        }
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
        if indexPath.row == 0{
            cell.seeAllButton.isHidden = true
            cell.cellBg.backgroundColor = UIColor.black
            cell.sectionHeader.textColor = UIColor.white
            cell.sectionHeader.text = sectionHeaders[0]

        }else{
            cell.seeAllButton.isHidden = false
            cell.sectionHeader.text = sectionHeaders[indexPath.row]
            cell.cellBg.backgroundColor = UIColor.white
            cell.sectionHeader.textColor = UIColor.black

        }

        let category = self.categories[indexPath.row]
        cell.setCollectionViewDataSourceDelegate(index: indexPath,stations:category.Stations)
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
//        playTrack(station: (self.categories[k!.row].categories?[indexPath.row].stations.first)!)
        print("Location:\(k!.row) \(indexPath.row)")
    }

    func playTrack(station:Station){
        tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: playerBlur.frame.height, right: 0)
        trackPlayerView.isHidden = false
        let musicURL = URL(string:station.stream)

        self.audioPlayer = AVPlayer(url: musicURL!)
        self.audioPlayer?.play()
        playPauseButton.setImage(UIImage(named:"pause"), for: .normal)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        mTrackImage.setImageWithUrl(url: NSURL(string:station.image)!)
        mTrackName.text = station.name
        mArtistName.text = station.id
    }

    @objc func updateProgressBar(){

            let t1 =  self.audioPlayer?.currentTime()
            let t2 =  self.audioPlayer?.currentItem?.asset.duration

            let current = CMTimeGetSeconds(t1!)
            let total =  CMTimeGetSeconds(t2!)

        if Int(current) != Int(total){

            let min = Int(current) / 60
            let sec =  Int(current) % 60
            mDuration.text = String(format: "%02d:%02d", min,sec)
            let percent = (current/total)

            self.progressBar.setProgress(Float(percent), animated: true)
            print("percent \(percent) - \(current) \(total)")
        }else{
            audioPlayer?.pause()
            audioPlayer = nil
            myTimer.invalidate()
            myTimer = nil
        }
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
