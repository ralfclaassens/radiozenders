import UIKit

protocol MusicCellProtocol {
    func didTapSeeAll(cell: MusicCell, indexPath: IndexPath)
    func didTapOnTrack(cell: MusicCell, indexPath: IndexPath)
}

class MusicCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            let nib = UINib(nibName: "TrackCell", bundle: nil)
            self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        }
    }

    @IBOutlet weak var sectionHeader: UILabel!
    @IBOutlet weak var cellBg: UIView!
    @IBOutlet weak var seeAllButton: UIButton!

    var indexPath:IndexPath?
    var delegate:MusicCellProtocol? = nil
    var stations:[Station]?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func didTapOnSeeAll(_ sender: Any) {
        if let _  = delegate{
            delegate?.didTapSeeAll(cell: self, indexPath: indexPath!)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCollectionViewDataSourceDelegate(index: IndexPath, stations: [Station]){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        indexPath = index
        self.stations = stations
        self.collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return stations!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackCell
        let obj = stations?[indexPath.row]
        let imageBase = "https://www.radiozenders.fm/media/images/stations/"
        cell.name.text = obj!.name
        cell.coverImage.setImageWithUrl(url: NSURL(string:imageBase + (obj?.image)!)!)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Coll:\(indexPath) - \(String(describing: self.indexPath))")
        if let _ = delegate{
            delegate?.didTapOnTrack(cell: self, indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }

}
