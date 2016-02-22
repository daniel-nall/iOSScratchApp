import Foundation
import RealmSwift

class DownloadQueue: Object {
    var queue: [Download]?
    var RLMqueue = List<Download>()
    
    required init() {
        super.init()
    }
    
    override static func ignoredProperties() -> [String] {
        return ["queue"]
    }
}