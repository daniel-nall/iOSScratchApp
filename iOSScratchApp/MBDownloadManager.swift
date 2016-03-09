import Foundation
import Alamofire
import RealmSwift

class MBDownloadManger {
    static let sharedInstance = MBDownloadManger()
    
    var downloadQueueList = List<DownloadQueue>()
    
    // MARK: download queue creation
    func addDownloadQueue(playlist: Playlist) {
        let queue = DownloadQueue()
        for song in playlist.RLMsongs {
            let download = Download()
            if let id = song.id {
                MBAPIHandler.sharedInstance.getSongURL(id) {
                    result in
                    download.downloadStateRaw = "Pending"
                    print(download.state)
                    download.songId = song.id
                    download.songURL = result
                    download.largeImagePath = song.album?.image?.getImageURL(.LargeImage)
                    download.smallImagePath = song.album?.image?.getImageURL(.SmallImage)
                    queue.queue.append(download)
                    
                    if queue.queue.count == playlist.RLMsongs.count {
                        self.downloadQueueList.append(queue)
                        MBRealmManager.sharedInstance.addDownloadQueueToRealm(queue)
                        if self.downloadQueueList.count == 1 {
                            self.beginDownload()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: outer loop
    func beginDownload() {
        self.downloadItem(self.downloadQueueList[0], currentItem: 0) {
            MBRealmManager.sharedInstance.deleteDownloadQueue(self.downloadQueueList[0])
            self.downloadQueueList.removeAtIndex(0)
            if !self.downloadQueueList.isEmpty {
                self.beginDownload()
            }
        }
    }
    
    // MARK: inner loop
    func downloadItem(queue: DownloadQueue, var currentItem: Int, completion: () -> Void) {
        guard currentItem < queue.queue.count else {
            completion()
            return
        }
        
        let item = queue.queue[currentItem]
        let downloadGroup = dispatch_group_create()
        
        if let songId = item.songId, let songURL = item.songURL, let largeImagePath = item.largeImagePath, let smallImagePath = item.smallImagePath {
            dispatch_group_enter(downloadGroup)
            download(songURL) {
                path in
                if let localPath = path {
                    MBRealmManager.sharedInstance.updateSongURL(songId, localPath: localPath)
                }
                dispatch_group_leave(downloadGroup)
            }
            
            dispatch_group_enter(downloadGroup)
            download(largeImagePath) {
                path in
                if let localPath = path {
                    MBRealmManager.sharedInstance.updateLargeImageURL(songId, localPath: localPath)
                }
                dispatch_group_leave(downloadGroup)
            }
            
            dispatch_group_enter(downloadGroup)
            download(smallImagePath) {
                path in
                if let localPath = path {
                    MBRealmManager.sharedInstance.updateSmallImageURL(songId, localPath: localPath)
                }
                dispatch_group_leave(downloadGroup)
            }
            
            dispatch_group_notify(downloadGroup, dispatch_get_main_queue()) {
                // FIXME: figure out how we want to handle download state from here
                self.downloadItem(queue, currentItem: ++currentItem, completion: completion)
            }
        }
    }
    
    // MARK: individual download
    func download(url: String, completion: (String?) -> Void) {
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
        Alamofire.download(.GET, url, destination: destination).response {
            request, response, _, error in
            var localPath: NSURL?
            if let theError = error {
                print("Failed with error: \(theError)")
                localPath = destination(NSURL(string: "")!, response!)
            } else {
                localPath = destination(NSURL(string: "")!, response!)
            }
            completion(localPath?.absoluteString)
        }
    }
}