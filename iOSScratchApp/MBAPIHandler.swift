import Foundation
import Alamofire
import ObjectMapper

class MBAPIHandler {
    
    static let sharedInstance = MBAPIHandler()
    
    private let userDefaults: NSUserDefaults
    private var userToken : String? {
        get {
            return userDefaults.objectForKey("userToken") as? String
        }
        set {
            userDefaults.setObject(newValue, forKey: "userToken")
            userDefaults.synchronize()
        }
    }
    
    // MARK: initializer
    init() {
        userDefaults = NSUserDefaults()
    }
    
    // MARK: Validate Authentication
    func isUserAuthenticated() -> Bool {
        return userToken != nil
    }
    
    // MARK: API Calls
    func getLoginToken(username: String, password: String, completion: String? -> Void) {
        let loginURL = "https://api.musicbed.com/v1/auth?login=\(username)&password=\(password)"
        
        Alamofire.request(.POST, loginURL).responseObject {
            (response: Response<Login, NSError>) in
            let loginResponse = response.result.value
            self.userToken = loginResponse?.loginToken
            completion(self.userToken)
        }
    }
    
    func getPlaylistCollection(completion: [Playlist]? -> Void) {
        let playlistURL = "https://api.musicbed.com/v1/playlists"
        
        if let theToken = userToken {
            Alamofire.request(.GET, playlistURL, headers: ["X-Token": theToken]).responseArray {
                (response: Response<[Playlist], NSError>) in
                let playlistResponse : [Playlist]? = response.result.value
                completion(playlistResponse)
            }
        }
    }
    
    func getPlaylistById(playlistId: String, completion: Playlist? -> Void) {
        let songListURL = "https://api.musicbed.com/v1/playlists/\(playlistId)"
        
        if let theToken = userToken {
            Alamofire.request(.GET, songListURL, headers: ["X-Token": theToken]).responseObject {
                (response: Response<Playlist, NSError>) in
                let playlistResponse: Playlist? = response.result.value
                completion(playlistResponse)
            }
        }
    }
    
    func getSongURL(songId: String, completion: String? -> Void) {
        let requestURL = "https://api.musicbed.com/v1/songs/\(songId)/url"
        var songURL: String?
        
        if let theToken = userToken {
            Alamofire.request(.GET, requestURL, headers: ["X-Token": theToken]).responseJSON {
                response in
                if let theResponse = response.result.value as? [String: String] {
                    songURL = theResponse["url"]
                }
                completion(songURL)
            }
        }
    }
    
    func getSongInfo(songId: String, completion: Song? -> Void) {
        let songInfoURL = "https://api.musicbed.com/v1/songs/\(songId)"
        
        if let theToken = userToken {
            Alamofire.request(.GET, songInfoURL, headers: ["X-Token": theToken]).responseObject {
                (response: Response<Song, NSError>) in
                let songResponse: Song? = response.result.value
                completion(songResponse)
            }
        }
    }
}