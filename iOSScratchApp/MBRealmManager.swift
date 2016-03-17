import Foundation
import RealmSwift

class MBRealmManager {
    
    var realm: Realm?
    
    init() {
        realm = try! Realm()
    }
    
    // MARK: add functions
    func addPlaylist(playlist: Playlist) {
        try! realm!.write {
            realm!.add(playlist)
        }
        
        MBDownloadManger.sharedInstance.addDownloadQueue(playlist)
    }
    
    func addDownloadQueueToRealm(queue: DownloadQueue) {
        try! realm!.write {
            realm!.add(queue)
        }
    }
    
    // MARK: load functions
    func loadPlaylistFromRealm(id: String, completion: (Bool, Playlist) -> Void) {
        if let result = realm!.objects(Playlist).filter("id == '\(id)'").first {
            completion(true, result)
        } else {
            completion(false, Playlist())
        }
    }
    
    // MARK: helper functions
    func isPlaylistSaved(playlist: Playlist) -> Bool {
        guard let id = playlist.id, let _ = realm!.objects(Playlist).filter("id == '\(id)'").first else {
            return false
        }
        return true
    }
    
    // MARK: update functions
    func updateLocalSongFile(id: String, localFile: String) {
        let songs = realm!.objects(Song).filter("id == '\(id)'")
        try! realm!.write {
            for song in songs {
                song.songFile = localFile
            }
        }
    }
    
    func updateLargeImageFile(id: String, localFile: String) {
        let songs = realm!.objects(Song).filter("id == '\(id)'")
        try! realm!.write {
            for song in songs {
                song.album?.image?.largeLocalFileName = localFile
            }
        }
    }
    
    func updateSmallImageFile(id: String, localFile: String) {
        let songs = realm!.objects(Song).filter("id == '\(id)'")
        try! realm!.write {
            for song in songs {
                song.album?.image?.smallLocalFileName = localFile
            }
        }
    }
    
    // MARK: delete functions
    func deletePlaylist(playlist: Playlist) {
        try! realm!.write {
            for song in playlist.RLMsongs {
                song.RLMDelete = true
                song.album?.RLMDelete = true
                song.album?.image?.RLMDelete = true
                song.album?.artist?.RLMDelete = true
            }
            
            playlist.image?.RLMDelete = true
            playlist.RLMDelete = true
        }
    }
    
    func deleteDownloadQueue(queue: DownloadQueue) {
        try! realm!.write {
            for download in queue.queue {
                realm!.delete(download)
            }
            realm!.delete(queue)
        }
    }
    
    func cleanRealm() {
        let songsToDelete = realm!.objects(Song).filter("RLMDelete == true")
        for song in songsToDelete {
            if let songFileName = song.songFile, let songPath = LocalFile.applicationDocumentsDirectory(songFileName), let songURL = NSURL(string: songPath) {
                LocalFile.deleteFileIfExists(songURL)
            }
        }
        
        let playlistsToDelete = realm!.objects(Playlist).filter("RLMDelete == true")
        let albumsToDelete = realm!.objects(Album).filter("RLMDelete == true")
        for album in albumsToDelete {
            if let smallImage = album.image?.smallLocalFileName, let smallImagePath = LocalFile.applicationDocumentsDirectory(smallImage), let smallImageURL = NSURL(string: smallImagePath) {
                LocalFile.deleteFileIfExists(smallImageURL)
            }
            
            if let largeImage = album.image?.largeLocalFileName, let largeImagePath = LocalFile.applicationDocumentsDirectory(largeImage), let largeImageURL = NSURL(string: largeImagePath) {
                LocalFile.deleteFileIfExists(largeImageURL)
            }
        }
        
        let artistsToDelete = realm!.objects(Artist).filter("RLMDelete == true")
        let imagesToDelete = realm!.objects(MBImage).filter("RLMDelete == true")
        
        try! realm!.write {
            realm!.delete(songsToDelete)
            realm!.delete(playlistsToDelete)
            realm!.delete(albumsToDelete)
            realm!.delete(artistsToDelete)
            realm!.delete(imagesToDelete)
        }
    }
}