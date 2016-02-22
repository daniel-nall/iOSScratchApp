import Foundation
import ObjectMapper

class Login: Mappable {
    var loginToken: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        loginToken <- map["token"]
    }
}