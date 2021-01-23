//
//  ViewController.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-08.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import UIKit
import VisionKit

class VisionKit: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func cameraButton(_ sender: Any) {
        configureDocumentView()
    }
    
    private func configureDocumentView(){
        let scanningDocumentVC = VNDocumentCameraViewController()
        scanningDocumentVC.delegate = self
        self.present(scanningDocumentVC, animated: true, completion: nil)
    }
    
    
}

extension VisionKit:VNDocumentCameraViewControllerDelegate{
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for pageNumber in 0..<scan.pageCount{
            let image = scan.imageOfPage(at: pageNumber)
            print(image)
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
