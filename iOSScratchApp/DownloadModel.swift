import Foundation
import RealmSwift

enum DownloadState {
    case Active
    case Pending
    case AwaitingConnection
}

class Download: Object {
    var state: DownloadState?
    dynamic var songId: String?
    dynamic var path: String?
    
    required init() {
        super.init()
    }
}