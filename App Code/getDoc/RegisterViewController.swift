//
//  RegisterViewController.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-13.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var fullNameTextField: UITextField!
    @IBOutlet var retypePassword: UITextField!
    @IBOutlet var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = false
        passwordTextField.text = "Password"
        retypePassword.isSecureTextEntry = false
        retypePassword.text = "Re-type Password"
        emailTextField.isSecureTextEntry = false
        emailTextField.text = "E-mail"
        fullNameTextField.isSecureTextEntry = false
        fullNameTextField.text = "Full Name"
        hideKeyboardWhenTappedAround()
        self.navigationController?.navigationBar.isHidden = true
        registerButton.addTarget(self, action: #selector(makeUser), for: .touchUpInside)
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
    
    
    @IBAction func retypePasswordTextFieldDidChange(_ sender: Any) {
        if(retypePassword.text == ""){
            retypePassword.isSecureTextEntry = false
            retypePassword.text = "Re-type Password"
        }
    }
    @IBAction func retypePasswordTextFieldEditingBegan(_ sender: Any) {
        retypePassword.text = ""
        retypePassword.isSecureTextEntry = true
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
    
    @IBAction func fullnameTextFieldDidChange(_ sender: Any) {
        if(fullNameTextField.text == ""){
            fullNameTextField.isSecureTextEntry = false
            fullNameTextField.text = "Full Name"
        }
    }
    @IBAction func fullNameTextFieldEditingBegan(_ sender: Any) {
        fullNameTextField.text = ""
    }
    
    
    func createUserStorageDirectory(){
        FirebaseUtilities.savePicture(image: UIImage(named: "no-image")!, name: "\(emailTextField.text!)/no-image")
    }
    
    @objc func makeUser(){
        if(emailTextField.text! != "" || passwordTextField.text! != ""){
            if(isValidEmail(emailTextField.text!) == true && isValidPassword(passwordTextField.text!) == true){
                FirebaseUtilities.makeUser(Email: emailTextField.text!, Password: passwordTextField.text!)
                createUserStorageDirectory()
                performSegue(withIdentifier: "register", sender: self)
            }else{
                let alert = UIAlertController(title: "Error", message: "Invalid Email Format. Email must follow format: someone@example.com. Password must have atleast one uppercase and lowercase letter, one digit, one special characters, and must be at least 8 characters long.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Error", message: "One or both fields are empty. Please fill them in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    
    @IBAction func privatePolicyButtonClicked(_ sender: Any) {
        UIApplication.shared.open(NSURL(string: "https://scanaiprivatepolicy.netlify.app")! as URL)
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
        if(segue.identifier == "register"){
            let segueDest = segue.destination as? DocumentScanViewController
            DocumentScanViewController.folder_name = emailTextField.text!
        }
    }
}




