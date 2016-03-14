import Foundation
import ObjectMapper
import RealmSwift

enum ImageSize {
    case SmallImage
    case LargeImage
}

class MBImage: Object, Mappable {
    dynamic var basePath: String?
    dynamic var fileName: String?
    dynamic var id: String?
    dynamic var smallImageURL: String?
    dynamic var largeLocalFileName: String?
    dynamic var smallLocalFileName: String?
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
    
    func getImageURL(size: ImageSize) -> String? {
        switch size {
        case .SmallImage:
            if let localFile = smallLocalFileName {
                let documentsDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let path = documentsDir.URLByAppendingPathComponent(localFile).path
                print("small: \(path)")
                return path
            } else {
                if let path = smallImageURL {
                    return path
                }
            }
            break
        case .LargeImage:
            if let localFile = largeLocalFileName {
                let documentsDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let path = documentsDir.URLByAppendingPathComponent(localFile).path
                print("large: \(path)")
                return path
            } else {
                if let path = basePath, let file = fileName {
                    return "\(path)/\(file)"
                }
            }
            break
        }
        return nil
    }
}