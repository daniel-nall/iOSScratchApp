import Foundation
import RealmSwift

class MBRealmManager {
    static let sharedInstance = MBRealmManager()
    
    let realm = try! Realm()
    
    func downloadPlaylist(playlist: Playlist) {
        try! realm.write {
            realm.add(playlist)
        }
    }
    
    func loadPlaylistFromRealm(id: String, completion: (Playlist?) -> Void) {
        if let result = realm.objects(Playlist).filter("id == '\(id)'").first {
            completion(result)
        } else {
            completion(nil)
        }
    }
    
    func isPlaylistSaved(playlist: Playlist) -> Bool {
        guard let id = playlist.id, let _ = realm.objects(Playlist).filter("id == '\(id)'").first else {
            return false
        }
        return true
    }
    
    func deletePlaylist(playlist: Playlist) {
        //if let thePlaylist = realm.objects(Playlist).filter("id == '\(playlist.id)'").first {
            try! realm.write {
                for song in playlist.RLMsongs {
                    song.RLMDelete = true
                    song.album?.RLMDelete = true
                    song.album?.image?.RLMDelete = true
                    song.album?.artist?.RLMDelete = true
                }
                
                playlist.image?.RLMDelete = true
                playlist.RLMDelete = true
            }
        //}
    }
    
    func cleanRealm() {
        let songsToDelete = realm.objects(Song).filter("RLMDelete == true")
        let playlistsToDelete = realm.objects(Playlist).filter("RLMDelete == true")
        let albumsToDelete = realm.objects(Album).filter("RLMDelete == true")
        let artistsToDelete = realm.objects(Artist).filter("RLMDelete == true")
        let imagesToDelete = realm.objects(MBImage).filter("RLMDelete == true")
        
        try! realm.write {
            realm.delete(songsToDelete)
            realm.delete(playlistsToDelete)
            realm.delete(albumsToDelete)
            realm.delete(artistsToDelete)
            realm.delete(imagesToDelete)
        }
    }
}