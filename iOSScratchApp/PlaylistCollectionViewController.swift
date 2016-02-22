import UIKit
import SDWebImage

class PlaylistCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var playlistCollectionView: UICollectionView!
    
    var playlistCollection: [Playlist]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBAPIHandler.sharedInstance.getPlaylistCollection {
            result in
            self.playlistCollection = result
            self.playlistCollectionView.reloadData()
        }
        
        playlistCollectionView.dataSource = self
        playlistCollectionView.delegate = self
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let theCollection = playlistCollection {
            return theCollection.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playlistTile", forIndexPath: indexPath) as! PlaylistCollectionViewCell
        if let name = playlistCollection?[indexPath.row].name, let imageURL = playlistCollection?[indexPath.row].image?.getImageURL() {
            cell.playlistName.text = name
            cell.playlistImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor())) {
                _ in
                cell.playlistImage.fadeIn(completion: nil)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: collectionView.frame.size.width/2)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showPlaylistSongsSegue", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPlaylistSongsSegue" {
            let playlistViewController = segue.destinationViewController as! PlaylistViewController
            let selectedPlaylistId = playlistCollection?[sender as! Int].id
            
            playlistViewController.playlistId = selectedPlaylistId
        }
    }
}
