import Foundation
import ObjectMapper
import RealmSwift

class Artist: Object, Mappable {
    dynamic var id: String?
    dynamic var name: String?
    var biography: String?
    var featured: String?
    dynamic var RLMDelete = false
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        biography <- map["biography"]
        featured <- map["featured"]
    }
    
    override static func ignoredProperties() -> [String] {
        return ["biography", "featured"]
    }
}