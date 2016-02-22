import Foundation
import Alamofire

class MBDownloadManger {
    static let sharedInstance = MBDownloadManger()
    
    var downloadQueueList: [DownloadQueue]?
    var isDownloading: Bool = false
    
//    func downloadSongsInPlaylist(songId: String, songURL: String?) {
//        if let url = songURL {
//            var download: Download?
//            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
//            Alamofire.download(.GET, url, destination: destination).progress {
//                _, _, _ in
//                download = Download(id: songId)
//                if let theDownload = download {
//                    MBDownloadManger.sharedInstance.downloadQueue?.append(theDownload)
//                }
//            }.response {
//                request, response, data, error in
//                if error != nil {
//                    print("Failed with error: \(error)")
//                } else {
//                    if let theDownload = download {
//                        if let index = MBDownloadManger.sharedInstance.downloadQueue?.indexOf({ $0.songId == theDownload.songId }) {
//                            MBDownloadManger.sharedInstance.downloadQueue?.removeAtIndex(index)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func downloadItem(queue: DownloadQueue, currentItem: Int) {
        
    }
}