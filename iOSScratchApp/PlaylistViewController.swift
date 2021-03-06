import Foundation
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
        
        downloadSwitch.enabled = false
        
        fetchPlaylist {
            self.didRetrievePlaylist()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        MBRealmManager().cleanRealm()
    }
    
    func didRetrievePlaylist() {
        tableView.reloadData()
        title = playlist.name
        if let imageURL = playlist.image?.getImageURL(.LargeImage) {
            playlistImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor())) {
                _ in
                self.playlistImage.fadeIn(completion: nil)
            }
        }
        
        downloadSwitch.on = MBRealmManager().isPlaylistSaved(playlist)
        downloadSwitch.enabled = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.RLMsongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell") as! PlaylistTableViewCell
        if let name = playlist.RLMsongs[indexPath.row].name, let imageURL = playlist.RLMsongs[indexPath.row].album?.image?.getImageURL(.SmallImage) {
            cell.songName.text = name
            
            let range = imageURL.rangeOfString("http")
            if let theRange = range where theRange.startIndex == imageURL.startIndex { // imageURL starts with "http" (remote url)
                cell.albumImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor())) {
                    _ in
                    cell.albumImage.fadeIn(completion: nil)
                }
            } else {
                cell.albumImage.sd_setImageWithURL(NSURL(fileURLWithPath: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor())) {
                    _ in
                    cell.albumImage.fadeIn(completion: nil)
                }
            }
        }
        return cell
    }
    
    func applicationDocumentsDirectory() -> NSURL? {
        
        let paths : NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let basePath: AnyObject! = (paths.count > 0) ? paths.objectAtIndex(0) : nil
        
        return NSURL(fileURLWithPath: basePath as! String, isDirectory: true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        fetchPlaylist {
            MBPlayerManager.sharedInstance.loadNewPlaylist(self.playlist.RLMsongs, index: indexPath.row) {
                self.performSegueWithIdentifier("playSongSegue", sender: indexPath.row)
            }
        }
    }
    
    func fetchPlaylist(completion: () -> Void) {
        if let id = playlistId {
            MBRealmManager().loadPlaylistFromRealm(id) {
                valid, result in
                if valid {
                    self.playlist = result
                    completion()
                } else {
                    MBAPIHandler.sharedInstance.getPlaylistById(id) {
                        result in
                        if let thePlaylist = result {
                            self.playlist = thePlaylist
                        }
                        completion()
                    }
                }
            }
        }
    }
    
    @IBAction func downloadTapped(sender: UISwitch) {
        if sender.on {
            MBRealmManager().addPlaylist(playlist)
        } else {
            MBRealmManager().deletePlaylist(playlist)
        }
    }
}
