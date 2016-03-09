import Foundation
import AVFoundation
import MediaPlayer
import RealmSwift

enum PlayState {
    case Playing
    case Paused
}

class MBPlayerManager: NSObject {
    static let sharedInstance = MBPlayerManager()
    
    var delegate: MBPlayerManagerDelegate?
    
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVPlayer?
    
    var songList: List<Song>?
    var currentSong: Song?
    var currentSongIndex: Int?
    
    var playState: PlayState?
    
    // MARK: Setup
    override init() {
        super.init()
        
        MPRemoteCommandCenter.sharedCommandCenter().playCommand.addTarget(self, action: "togglePlay")
        MPRemoteCommandCenter.sharedCommandCenter().pauseCommand.addTarget(self, action: "togglePlay")
        MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.addTarget(self, action: "previousSong")
        MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.addTarget(self, action: "nextSong")
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    func setupAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionWasInterrupted:", name: AVAudioSessionInterruptionNotification, object: audioSession)
    }
    
    func setupAudioPlayer(url: String?) {
        if let urlString = url, let theURL = NSURL(string: urlString) {
            self.audioPlayer = AVPlayer(URL: theURL)
        }
        
        if let songName = currentSong?.name, let albumName = currentSong?.album?.name, let albumImageURL = currentSong?.album?.image?.getImageURL(.LargeImage), let albumImageNSURL = NSURL(string: albumImageURL), let albumImageData = NSData(contentsOfURL: albumImageNSURL), let albumUIImage = UIImage(data: albumImageData), let artistName = currentSong?.album?.artist?.name {
            let albumArt = MPMediaItemArtwork(image: albumUIImage)
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                MPMediaItemPropertyTitle: songName,
                MPMediaItemPropertyAlbumTitle: albumName,
                MPMediaItemPropertyArtwork: albumArt,
                MPMediaItemPropertyArtist: artistName
            ]
        }
        
        if let thePlayer = audioPlayer {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: thePlayer.currentItem)
            self.playAudio()
        }
    }
    
    // MARK: Events
    func playerDidFinishPlaying(notification: NSNotification) {
        nextSong()
    }
    
    func audioSessionWasInterrupted(notification: NSNotification) {
        if let userInfo = notification.userInfo, let type = AVAudioSessionInterruptionType(rawValue: userInfo[AVAudioSessionInterruptionTypeKey] as! UInt) {
            switch type {
            case .Began:
                pauseAudio(true)
            case .Ended:
                let options = AVAudioSessionInterruptionOptions(rawValue: userInfo[AVAudioSessionInterruptionOptionKey] as! UInt)
                if options == AVAudioSessionInterruptionOptions.ShouldResume && playState == .Playing {
                    playAudio()
                }
            }
        }
    }
    
    // MARK: load functions
    func loadNewPlaylist(list: List<Song>, index: Int, completion: () -> Void) {
        songList = list
        currentSong = list[index]
        currentSongIndex = index
        fetchSongURL(index) {
            completion()
        }
    }
    
    func fetchSongURL(index: Int, completion: (() -> Void)?) {
        if let songURL = self.currentSong?.songURL {
            self.setupAudioPlayer(songURL)
            self.delegate?.didStartNewSong()
            completion?()
        } else {
            if let songId = songList?[index].id {
                MBAPIHandler.sharedInstance.getSongURL(songId) {
                    result in
                    self.setupAudioPlayer(result)
                    self.currentSong?.songURL = result
                    self.delegate?.didStartNewSong()
                    completion?()
                }
            }
        }
    }
    
    // MARK: audio functions
    func togglePlay() {
        if playState == .Playing {
            self.pauseAudio()
        } else {
            self.playAudio()
        }
    }
    
    private func playAudio() {
        do {
            try audioSession.setActive(true)
            self.audioPlayer?.play()
            self.playState = .Playing
            self.delegate?.isPlaying()
        } catch {}
    }
    
    private func pauseAudio(interrupt: Bool = false) {
        audioPlayer?.pause()
        if !interrupt {
            playState = .Paused
        }
        self.delegate?.isPausing()
    }
    
    func nextSong() {
        if let index = self.currentSongIndex, let list = songList where index != list.count - 1 {
            currentSong = list[index + 1]
            currentSongIndex = index + 1
            fetchSongURL(index + 1, completion: nil)
        } else {
            pauseAudio()
            self.delegate?.didFinishPlaying()
        }
    }
    
    func previousSong() {
        if let index = self.currentSongIndex, let list = songList where index != 0 {
            currentSong = list[index - 1]
            currentSongIndex = index - 1
            fetchSongURL(index - 1, completion: nil)
        } else {
            pauseAudio()
            self.delegate?.didFinishPlaying()
        }
    }
}

protocol MBPlayerManagerDelegate {
    
    // MARK: Delegate functions
    func isPlaying()
    
    func isPausing()
    
    func didStartNewSong()
    
    func didFinishPlaying()
}