//
//  FirebaseUtilities.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-13.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import Firebase
import FirebaseAuth

class FirebaseUtilities{
    static let db = Firestore.firestore()
    static let storage = Storage.storage()
    
    static func makeUser(Email: String, Password: String){
        Auth.auth().createUser(withEmail: Email, password: Password) { (authResult, error) in
            if(error != nil){
                print("Error: \(error!.localizedDescription)")
            }else{
                print("Successful Registration")
                db.collection("Users").addDocument(data: ["Email": Email, "Password": Password]) { (error) in
                    if(error != nil){
                        print("Error: \(error!.localizedDescription)")
                    }else{
                        print("Successful Addition")
                    }
                }
            }
        }
    }
    
    static func signin(Email: String, Password: String){
        Auth.auth().signIn(withEmail: Email, password: Password) { (authResult, error) in
            if(error != nil){
                print("Error: \(error!.localizedDescription)")
            }else{
                let vc = SignInViewController()
                vc.performSegue(withIdentifier: "signin", sender: self)
                                
                print("Successful Sign In")
            }
        }
    }
    
    
    
    static func signOut(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    static func savePicture(image: UIImage, name: String){
        let imgRef = storage.reference().child("\(name).jpg")
//        let metadata = StorageMetadata()
        
        if let uploadData = image.jpegData(compressionQuality: 0.5){
            imgRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if(error != nil){
                    print("Error: \(error!.localizedDescription)")
                }else{
                    print("Uploaded Picture")
                }
            }
        }
        sleep(UInt32(1))
    }
    
}


/*
 Greetings Mr. Odeski,

 My name is Rohan, I am a senior high school student. I am currently developing an IOS App and I would love to discuss some problems I am running into with you.

 Would you be comfortable hopping on a 15-20 minute zoom call? It would mean a lot!

 Thank you for your time,

 Rohan
*/
 
