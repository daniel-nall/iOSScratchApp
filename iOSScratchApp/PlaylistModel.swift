import Foundation
import ObjectMapper
import RealmSwift

class Playlist: Object, Mappable {
    dynamic var active: String? = nil
    dynamic var categoryId: String? = nil
    dynamic var desc: String? = nil
    dynamic var featured: String? = nil
    dynamic var id: String? = nil
    dynamic var image: MBImage?
    dynamic var name: String? = nil
    var songs: [Song]?
    dynamic var RLMDelete = false
    var RLMsongs = List<Song>()
    
    required  convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        active <- map["active"]
        categoryId <- map["category_id"]
        desc <- map["description"]
        featured <- map["featured"]
        id <- map["id"]
        image <- map["image_object"]
        name <- map["name"]
        songs <- map["songs"]
        if let songsArray = songs {
            for song in songsArray {
                RLMsongs.append(song)
            }
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["songs"]
    }
}