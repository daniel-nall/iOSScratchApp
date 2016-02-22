import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController?
    var viewControllerArray: [UIViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        
        pageViewController?.dataSource = self
        
        if let signUpViewController = storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as? SignUpViewController,
            let launchViewController = storyboard?.instantiateViewControllerWithIdentifier("LaunchViewController") as? LaunchViewController,
            let loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
                viewControllerArray = [signUpViewController,launchViewController,loginViewController]
        }
        
        if let thePageViewController = pageViewController, let theArray = viewControllerArray {
            thePageViewController.setViewControllers([theArray[1]], direction: .Forward, animated: true, completion: nil)
            
            thePageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.addChildViewController(thePageViewController)
            self.view.addSubview(thePageViewController.view)
            thePageViewController.didMoveToParentViewController(self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if MBAPIHandler.sharedInstance.isUserAuthenticated() {
            if let mainNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("navCon") {
                self.presentViewController(mainNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard var index = self.getViewControllerIndex(viewController), let theArray = viewControllerArray else {
            return nil
        }
        
        if index != 0 {
            return theArray[--index]
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard var index = self.getViewControllerIndex(viewController), let theArray = viewControllerArray else {
            return nil
        }
        
        if index != theArray.count - 1 {
            return theArray[++index]
        } else {
            return nil
        }
    }
    
    func getViewControllerIndex(viewController: UIViewController) -> Int? {
        if let index = viewControllerArray?.indexOf(viewController) {
            return index
        } else {
            return nil
        }
    }

}
