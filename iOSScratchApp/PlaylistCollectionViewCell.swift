import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistName: UILabel!
    
    override func prepareForReuse() {
        playlistImage.image = nil
        playlistImage.fadeOut(completion: nil)
        super.prepareForReuse()
    }
}
