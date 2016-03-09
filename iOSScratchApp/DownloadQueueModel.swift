import Foundation
import RealmSwift

class DownloadQueue: Object {
    var queue = List<Download>()
}