import Foundation
import ObjectMapper
import RealmSwift

class Song: Object, Mappable {
    dynamic var id: String?
    dynamic var name: String?
    dynamic var lyrics: String?
    dynamic var duration: String?
    dynamic var featured: String?
    
    dynamic var album: Album?
    
    dynamic var songFile: String?
    
    dynamic var RLMDelete = false
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        lyrics <- map["lyrics"]
        duration <- map["duration"]
        featured <- map["featured"]
        album <- map["album"]
    }
    
    func getLocalPathForSong() -> String? {
        if let songFileName = songFile {
            return LocalFile.applicationDocumentsDirectory(songFileName)
        } else {
            return nil
        }
    }
}