import UIKit
import Alamofire
import AlamofireObjectMapper

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameText.delegate = self
        passwordText.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @IBAction func loginTapped(sender: AnyObject) {
        if let username = usernameText.text, let password = passwordText.text {
            MBAPIHandler.sharedInstance.getLoginToken(username, password: password) {
                token in
                if let _ = token, let playlistViewController = self.storyboard?.instantiateViewControllerWithIdentifier("navCon") {
                    self.presentViewController(playlistViewController, animated: true, completion: nil)
                }
            }
        }
    }
}
