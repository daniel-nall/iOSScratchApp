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
                return LocalFile.applicationDocumentsDirectory(localFile)
            } else {
                if let path = smallImageURL {
                    return path
                }
            }
            break
        case .LargeImage:
            if let localFile = largeLocalFileName {
                return LocalFile.applicationDocumentsDirectory(localFile)
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