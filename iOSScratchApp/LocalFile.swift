import Foundation

class LocalFile {
    class func applicationDocumentsDirectory(fileName: String) -> String? {
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let path = documentsDir.URLByAppendingPathComponent(fileName).path
        return path
    }
    
    class func deleteFileIfExists(fileURL: NSURL) {
        let fm = NSFileManager.defaultManager()
        
        let fileExists = fm.fileExistsAtPath(fileURL.path!)
        if fileExists {
            do {
                try fm.removeItemAtURL(fileURL)
                print("File deleted successfully:\n\(fileURL.path!)")
            }
            catch {
                print("Error deleting file:\n\(fileURL.path!)")
            }
        }
        else {
            print("No file found at:\n\(fileURL.path!)")
        }
    }
}