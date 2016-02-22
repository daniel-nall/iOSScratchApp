import Foundation
import AVFoundation

enum PlayState {
    case Playing
    case Paused
}

class MBPlayerManager: NSObject {
    static let sharedInstance = MBPlayerManager()
    
    var delegate: MBPlayerManagerDelegate?
    
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVPlayer?
    
    var songList: [Song]?
    var currentSong: Song?
    var currentSongIndex: Int?
    
    var playState: PlayState?
    
    // MARK: Setup
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
    
    // MARK: audio functions
    func loadNewPlaylist(list: [Song], index: Int, completion: () -> Void) {
        if let selectedSongId = list[index].id {
            MBAPIHandler.sharedInstance.getSongInfo(selectedSongId) {
                result in
                self.songList = list
                self.currentSong = result
                self.currentSongIndex = index
                MBAPIHandler.sharedInstance.getSongURL(selectedSongId) {
                    result in
                    self.setupAudioPlayer(result)
                    self.currentSong?.songURL = result
                }
                completion()
            }
        }
    }
    
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
        self.audioPlayer?.pause()
        if !interrupt {
            self.playState = .Paused
        }
        self.delegate?.isPausing()
    }
    
    func nextSong() {
        if let index = self.currentSongIndex, let list = songList where index != list.count - 1 {
            if let newSongId = list[index + 1].id {
                MBAPIHandler.sharedInstance.getSongInfo(newSongId) {
                    result in
                    self.currentSong = result
                    self.currentSongIndex = index + 1
                    MBAPIHandler.sharedInstance.getSongURL(newSongId) {
                        result in
                        self.setupAudioPlayer(result)
                        self.currentSong?.songURL = result
                    }
                    self.delegate?.didStartNewSong()
                }
            }
        } else {
            pauseAudio()
            self.delegate?.didFinishPlaying()
        }
    }
    
    func previousSong() {
        if let index = self.currentSongIndex, let list = songList where index != 0 {
            if let newSongId = list[index - 1].id {
                MBAPIHandler.sharedInstance.getSongInfo(newSongId) {
                    result in
                    self.currentSong = result
                    self.currentSongIndex = index - 1
                    MBAPIHandler.sharedInstance.getSongURL(newSongId) {
                        result in
                        self.setupAudioPlayer(result)
                        self.currentSong?.songURL = result
                    }
                    self.delegate?.didStartNewSong()
                }
            }
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