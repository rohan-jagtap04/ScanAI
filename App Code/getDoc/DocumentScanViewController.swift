//
//  DocumentScanViewController.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-13.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import UIKit
import VisionKit
import Darwin
import Firebase
import WebKit
import BSImagePicker
import Photos
import DropDown

class DocumentScanViewController: UIViewController, VNDocumentCameraViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    static var folder_name: String?
    var transferName: String?
    var folderList: [StorageReference]?
    lazy var storage = Storage.storage()
    @IBOutlet var toAnchorView: UIView!
    var SelectedAssets = [PHAsset]()
    var PhotoArray = [UIImage]()
    @IBOutlet var photoAddButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Photo Library","Files"]
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let myView = UIView(frame: navigationBar.frame)
//        navigationBar.topItem?.titleView = myView
//        guard let topView = navigationBar.topItem?.titleView else { return }
//        let bottomView = photoAddButton.topAnchor
        menu.anchorView = toAnchorView
        menu.direction = .top
        menu.topOffset = CGPoint(x: 0, y:-(menu.anchorView?.plainView.bounds.height)!)
        menu.selectionAction = { index, title in
            if(index == 0 && title == "Photo Library"){
                self.photoLibrary()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(DocumentScanViewController.folder_name ?? "No Folder Name")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("HEYYYYYYY")
            self.loadImages(folder_name: DocumentScanViewController.folder_name ?? "new_user/")
        }
    }
    
    func loadImages(folder_name: String){
        self.storage.reference().child(folder_name).listAll { (result, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.folderList = result.items
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    @IBAction func takePhotoPressed(_ sender: Any) {
       // menu.show()
        self.photoLibrary()
    }
    
    @IBAction func SignOutPressed(_ sender: Any) {
        FirebaseUtilities.signOut()
        performSegue(withIdentifier: "signout", sender: self)
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        configureDocumentView()
    }
    
    
    func photoLibrary(){
        let imagePicker = ImagePickerController()
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]

        presentImagePicker(imagePicker, animated: true) { (asset) in
            print("Image Selected")
        } deselect: { (asset) in
            print("Image Deselected")
        } cancel: { (asset) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("HEYYYYYYY")
                self.loadImages(folder_name: DocumentScanViewController.folder_name!)
            }
        } finish: { (assets) in
            for i in 0..<assets.count{
                self.SelectedAssets.append(assets[i])
            }
            self.convertAssetsToImage()

            for j in 0..<self.PhotoArray.count{
                FirebaseUtilities.savePicture(image: self.PhotoArray[j], name: "\(DocumentScanViewController.folder_name!)/\(self.dateFormatter())")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                print("HEYYYYYYY")
                self.loadImages(folder_name: DocumentScanViewController.folder_name!)
            }

            self.SelectedAssets.removeAll()
            self.PhotoArray.removeAll()
        } completion: {

        }
    }
    
    private func configureDocumentView(){
        let scanningDocumentVC = VNDocumentCameraViewController()
        scanningDocumentVC.delegate = self
        transferName = DocumentScanViewController.folder_name
        self.present(scanningDocumentVC, animated: true, completion: nil)
    }
    

    func dateFormatter()->String{
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.string(from: date)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for pageNumber in 0..<scan.pageCount{
            let image = scan.imageOfPage(at: pageNumber)
            FirebaseUtilities.savePicture(image: image, name: "\(DocumentScanViewController.folder_name!)/\(dateFormatter())")
            sleep(UInt32(0.5))
        }
        DocumentScanViewController.folder_name = transferName
        controller.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocCell", for: indexPath) as! FolderListCell
        cell.contentView.backgroundColor = UIColor(red: 17, green: 85, blue: 113, alpha: 1)
                
        folderList![(folderList!.count-1) - indexPath.row].getData(maxSize: 2 * 2048 * 2048) { (data, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                cell.cellImage.image = UIImage(data: data!)
            }
        }
        
        folderList![(folderList!.count-1) - indexPath.row].getMetadata { (metadata, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                cell.labelText.text = self.convertImageName(imageName: metadata!.name!)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DocumentInfoViewController") as? DocumentInfoViewController
        vc!.modalPresentationStyle = .fullScreen
        vc!.transferName = DocumentScanViewController.folder_name
        folderList![(folderList!.count-1) - indexPath.row].getData(maxSize: 2 * 2048 * 2048) { (data, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                vc!.documentImage.image = UIImage(data: data!)!
            }
        }
        
        folderList![(folderList!.count-1) - indexPath.row].getMetadata { (metadata, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                vc!.documentName.text = self.convertImageName(imageName: metadata!.name!)
                vc!.realDocumentName = metadata!.name!
            }
        }
        
        self.present(vc!, animated: true, completion: nil)
        DocumentScanViewController.folder_name = vc!.transferName!
        print("FOLDER NAME: \(DocumentScanViewController.folder_name!)")
    }
    
    func convertAssetsToImage() -> Void{
        if SelectedAssets.count != 0{
            for i in 0..<SelectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                self.PhotoArray.append(newImage! as UIImage)
            }
        }
    }
    
    func convertImageName(imageName:String)->String{
        var returnString = ""
        let result = imageName.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789-: ").inverted)
        
        let olDateFormatter = DateFormatter()
        olDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let oldDate = olDateFormatter.date(from: result)
        
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = "MMM dd yyyy h:mm a"
        
        if(oldDate != nil){
            returnString = convertDateFormatter.string(from: oldDate!)
        }else{
            returnString = "No-Image"
        }
        
        return returnString
        
    }
} 

//extension PHAsset {
//
//    var image : UIImage {
//        var thumbnail = UIImage()
//        let imageManager = PHCachingImageManager()
//        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
//            thumbnail = image!
//        })
//        return thumbnail
//    }
//}


