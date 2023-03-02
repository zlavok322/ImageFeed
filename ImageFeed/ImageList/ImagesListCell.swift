import UIKit
 
protocol ImageListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImageListCellDelegate?
    
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // отменяем загрузку, чтобы не было бага во время переиспользования ячейки
        imageViewCell.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(isLiked: Bool) {
        let imageLike = isLiked == true ? UIImage(named: "like_button_active") : UIImage(named: "like_button_no_active")
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.likeButton.setImage(imageLike, for: .normal)
        }
    }
}
