import UIKit
import WebKit
import Firebase

class DownloadedItemView: UIViewController {
    @IBOutlet weak var webView : WKWebView!
    var downloadItemURL : String?
    var storageRef : StorageReference?

    override func viewDidLoad() {
        super.viewDidLoad()

    storageRef?.downloadURL(completion: {(downloadURL,error) in
        print("url is \(downloadURL)")
        
        DispatchQueue.main.async {
            guard let url = downloadURL else {return}
            let urlrequest = URLRequest(url: url)
            self.webView.load(urlrequest)
            }
        })
    }
}
