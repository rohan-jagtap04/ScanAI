//
//  DocumentInfoViewController.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-28.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import UIKit
import Firebase
import DropDown

class DocumentInfoViewController: UIViewController {
    
    
    @IBOutlet var documentImage: UIImageView!
    @IBOutlet var documentName: UILabel!
    @IBOutlet var exportButtonPressed: UIButton!
    var realDocumentName: String?
    
    var transferName: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        exportButtonPressed.addTarget(self, action: #selector(exportPressed), for: .touchUpInside)
        
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let storageRef = Storage.storage().reference().child("\(self.transferName ?? "")/\(self.realDocumentName ?? "")")
        storageRef.delete { (error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                print("Document Deleted!")
            }
        }
        performSegue(withIdentifier: "back", sender: self)
    }
    
    
    @IBAction func saveLocallyButtonPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(documentImage.image!, self, #selector(saveError), nil)
        performSegue(withIdentifier: "back", sender: self)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "back"){
            let segueDest = segue.destination as? DocumentScanViewController
            DocumentScanViewController.folder_name = transferName
        }
    }
   
    @objc func exportPressed(){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.documentName.text!)", self.documentImage.image!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    func convertImageName(imageName:String)->String{
        let result = imageName.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789-: ").inverted)
        
        let olDateFormatter = DateFormatter()
        olDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let oldDate = olDateFormatter.date(from: result)
        
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = "MMM dd yyyy h:mm a"
        
        return convertDateFormatter.string(from: oldDate!)
        
    }
   
}
