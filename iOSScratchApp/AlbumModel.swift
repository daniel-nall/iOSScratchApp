import Foundation
import ObjectMapper
import RealmSwift

class Album: Object, Mappable {
    dynamic var id: String?
    dynamic var name: String?
    dynamic var artist: Artist?
    dynamic var image: MBImage?
    dynamic var RLMDelete = false
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        artist <- map["artist"]
        image <- map["image_object"]
    }
}