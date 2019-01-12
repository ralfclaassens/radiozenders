import UIKit

class TrackCell: UICollectionViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bgView.layer.shadowColor = UIColor.black.cgColor
        self.bgView.layer.shadowOffset = .zero
        self.bgView.layer.shadowOpacity = 0.45
        self.bgView.layer.shadowRadius = 8
        self.bgView.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.bgView.layer.shouldRasterize = true
        self.bgView.layer.cornerRadius = 4
        self.layer.cornerRadius =  4
        
    }
    
    
}
