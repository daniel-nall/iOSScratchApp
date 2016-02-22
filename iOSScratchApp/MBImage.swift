import Foundation
import ObjectMapper
import RealmSwift

class MBImage: Object, Mappable {
    var basePath: String?
    var fileName: String?
    var id: String?
    var smallImageURL: String?
    dynamic var localPath: String?
    dynamic var RLMDelete = false
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        basePath <- map["base_path"]
        fileName <- map["file"]
        id <- map["id"]
        smallImageURL <- map["small_image_url"]
    }
    
    func getImageURL() -> String? {
        if let path = basePath, let file = fileName {
            return "\(path)/\(file)"
        } else {
            return nil
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["basePath", "fileName", "smallImageURL"]
    }
}