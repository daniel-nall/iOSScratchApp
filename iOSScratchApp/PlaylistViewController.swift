import UIKit
import RealmSwift

class PlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var downloadSwitch: UISwitch!
    
    var playlistId: String?
    dynamic var playlist = Playlist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let id = playlistId {
            MBRealmManager.sharedInstance.loadPlaylistFromRealm(id) {
                valid, result in
                if valid {
                    self.playlist = result
                    self.didRetrievePlaylist()
                } else {
                    MBAPIHandler.sharedInstance.getPlaylistById(id) {
                        result in
                        if let thePlaylist = result {
                            self.playlist = thePlaylist
                            self.didRetrievePlaylist()
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        MBRealmManager.sharedInstance.cleanRealm()
    }
    
    func didRetrievePlaylist() {
        tableView.reloadData()
        title = playlist.name
        if let imageURL = playlist.image?.getImageURL() {
            playlistImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor())) {
                _ in
                self.playlistImage.fadeIn(completion: nil)
            }
        }
        //if let thePlaylist = playlist {
            downloadSwitch.on = MBRealmManager.sharedInstance.isPlaylistSaved(playlist)
        //}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.RLMsongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell") as! PlaylistTableViewCell
        if let name = playlist.RLMsongs[indexPath.row].name, let imageURL = playlist.RLMsongs[indexPath.row].album?.image?.smallImageURL {
            cell.songName.text = name
            cell.albumImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor())) {
                _ in
                cell.albumImage.fadeIn(completion: nil)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        MBPlayerManager.sharedInstance.loadNewPlaylist(playlist.RLMsongs, index: indexPath.row) {
            self.performSegueWithIdentifier("playSongSegue", sender: indexPath.row)
        }
    }
    
    @IBAction func downloadTapped(sender: UISwitch) {
        //if let thePlaylist = playlist {
            if sender.on {
                MBRealmManager.sharedInstance.downloadPlaylist(playlist)
            } else {
                MBRealmManager.sharedInstance.deletePlaylist(playlist)
            }
        //}
    }
}
