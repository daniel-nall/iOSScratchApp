import UIKit

extension UIView {
    func fadeIn(duration: NSTimeInterval? = 0.1, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(duration!, animations: { () -> Void in
            self.alpha = 1.0
            }) { (finished) -> Void in
                if let comp = completion {
                    comp(finished)
                }
        }
    }
    
    func fadeOut(duration: NSTimeInterval? = 0.1, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(duration!, animations: { () -> Void in
            self.alpha = 0.0
            }) { (finished) -> Void in
                if let comp = completion {
                    comp(finished)
                }
        }
    }
}