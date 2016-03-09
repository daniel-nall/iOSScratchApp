import Foundation
import RealmSwift

enum DownloadState: String {
    case Active
    case Pending
    case Finished
}

class Download: Object {
    dynamic var downloadStateRaw: String?
    var state: DownloadState {
        get {
            if let stateRaw = downloadStateRaw, let raw = DownloadState(rawValue: stateRaw) {
                return raw
            }
            return .Active
        }
    }
    
    dynamic var songId: String?
    dynamic var songURL: String?
    dynamic var largeImagePath: String?
    dynamic var smallImagePath: String?
}