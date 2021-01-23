//
//  SignInViewController.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-13.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import UIKit
import Firebase
import KeychainAccess

class SignInViewController: UIViewController {
    
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var SignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.isSecureTextEntry = false
        emailTextField.text = "E-mail"
        passwordTextField.isSecureTextEntry = false
        passwordTextField.text = "Password"
        self.navigationController?.navigationBar.isHidden = true
        hideKeyboardWhenTappedAround()
        SignInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        let keychain = Keychain(service: "com.FollowU.getDoc")
        emailTextField.text = keychain["Email"]
        passwordTextField.text = keychain["Password"]
        
    }
    
    @IBAction func emailTextFieldDidChange(_ sender: Any) {
        if(emailTextField.text == ""){
            emailTextField.isSecureTextEntry = false
            emailTextField.text = "E-mail"
        }
    }
    @IBAction func emailTextFieldEditingBegan(_ sender: Any) {
        emailTextField.text = ""
    
    }
    
    @IBAction func passwordTextFieldDidChange(_ sender: Any) {
        if(passwordTextField.text == ""){
            passwordTextField.isSecureTextEntry = false
            passwordTextField.text = "Password"
        }
    }
    
    @IBAction func passwordTextFieldEditingBegan(_ sender: Any) {
        passwordTextField.text = ""
        passwordTextField.isSecureTextEntry = true
    }
    
    @objc func signIn(){
        signin(Email: emailTextField.text!, Password: passwordTextField.text!)
    }
    
    func signin(Email: String, Password: String){
        Auth.auth().signIn(withEmail: Email, password: Password) { (authResult, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "signin", sender: self)
                //Save their info to keychain
                let keychain = Keychain(service: "com.FollowU.getDoc")
                keychain["Email"] = self.emailTextField.text
                keychain["Password"] = self.passwordTextField.text
                print("Successful Sign In")
            }
        }
    }

    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("EMAIL: \(emailTextField.text!)")
        if(segue.identifier == "signin"){
            let segueDest = segue.destination as? DocumentScanViewController
            DocumentScanViewController.folder_name = emailTextField.text!
        }
    }
    
   
}
