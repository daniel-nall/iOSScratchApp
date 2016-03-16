import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController, MBPlayerManagerDelegate {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    var seekTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seekTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime:", userInfo: nil, repeats: true)
        
        MBPlayerManager.sharedInstance.delegate = self
        
        didStartNewSong()
    }
    
    // MARK: IBActions
    @IBAction func slide(sender: UISlider) {
        if let timescale = MBPlayerManager.sharedInstance.audioPlayer?.currentItem?.duration.timescale {
            let seconds = CMTimeMakeWithSeconds(Double(sender.value), timescale)
            MBPlayerManager.sharedInstance.audioPlayer?.seekToTime(seconds)
        }
    }
    
    @IBAction func playTapped(sender: UIButton) {
        MBPlayerManager.sharedInstance.togglePlay()
    }
    
    @IBAction func backTapped(sender: UIButton) {
        MBPlayerManager.sharedInstance.previousSong()
    }
    
    @IBAction func forwardTapped(sender: UIButton) {
        MBPlayerManager.sharedInstance.nextSong()
    }
    
    // MARK: Events
    func updateTime(timer: NSTimer) {
        if let currentTime = MBPlayerManager.sharedInstance.audioPlayer?.currentTime() {
            seekBar.value = Float(CMTimeGetSeconds(currentTime))
        }
    }
    
    // MARK: MBPlayerManagerDelegate function implementations
    func isPlaying() {
        playButton.setImage(UIImage(named: "pause.jpg"), forState: .Normal)
        seekTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime:", userInfo: nil, repeats: true)
    }
    
    func isPausing() {
        playButton.setImage(UIImage(named: "play.jpg"), forState: .Normal)
        seekTimer?.invalidate()
        seekTimer = nil
    }
    
    func didStartNewSong() {
        if let imageURL = MBPlayerManager.sharedInstance.currentSong?.album?.image?.getImageURL(.LargeImage), let duration = MBPlayerManager.sharedInstance.currentSong?.duration {
            let range = imageURL.rangeOfString("http")
            if let theRange = range where theRange.startIndex == imageURL.startIndex { // imageURL starts with "http" (remote url)
                albumImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor()))
            } else {
                albumImage.sd_setImageWithURL(NSURL(fileURLWithPath: imageURL), placeholderImage: UIColor.imageFromColor(UIColor.grayColor()))
            }
            
            if let durationFloat = Float(duration) {
                seekBar.maximumValue = durationFloat
            }
        }
        self.title = MBPlayerManager.sharedInstance.currentSong?.name
    }
    
    func didFinishPlaying() {
        seekBar.value = seekBar.minimumValue
        MBPlayerManager.sharedInstance.audioPlayer?.seekToTime(CMTimeMakeWithSeconds(0.0, 1))
        playButton.setImage(UIImage(named: "play.jpg"), forState: .Normal)
    }
}