//
//  LoginSignUpViewController.swift
//  CourtFinder
//
//  Created by Christian Morte on 1/1/17.
//  Copyright © 2017 Christian Morte. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


class LoginViewController : UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // Email and password fields passed in from sign up screen
    var passedEmail: String? = nil
    var passedPassword: String? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To give the buttons a rounded corner
        loginButton.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
        
        if passedEmail != nil {
            emailTextField.text = passedEmail
        }
        if passedPassword != nil {
            passwordTextField.text = passedPassword
        }
        
        if emailTextField.text == nil || emailTextField.text?.characters.count == 0 ||
            passwordTextField.text == nil || passwordTextField.text?.characters.count == 0 {
            disableLoginButton()
        }
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // IMPORTANT!!! TO UNWIND ANOTHER SCREEN BACK TO LOGIN SCREEN
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        NSLog("unwind to login screen")
    }
    
    
    @IBAction func loginButtonClicked(_ sender: AnyObject) -> Void {
        
        if !loginButton.isEnabled {
            alertInvalidLogin(title: "No e-mail address or password provided", message: "You must provide a valid e-mail address and password combination in order to login.")
            return
        }
        
        if (isValidEmail() && isValidPassword()) {
            // Connects to the home screen
            performSegue(withIdentifier: "Login-Home", sender: nil)
            
        } else if (!doesEmailExist()) {
            alertInvalidLogin(title: "Invalid e-mail address.", message: "The e-mail address does not seem to be in our records. Please sign up to view the Court Finder app.")
            
        } else if (!isPasswordValidForEmail()) {
            alertInvalidLogin(title: "Invalid e-mail/password combination", message: "Please enter the e-mail/password combination again.")
        }
    }
    
    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "Login-SignUp", sender: nil)
    }
    
    @IBAction func emailTextChanged(_ sender: UITextField) {
        if sender.text != nil &&
            (sender.text?.characters.count)! > 0 &&
            (passwordTextField.text?.characters.count)! > 0 {
            enableLoginButton()
            
        } else {
            disableLoginButton()
        }
    }
    
    @IBAction func passwordTextChanged(_ sender: UITextField) {
        if sender.text != nil &&
            (sender.text?.characters.count)! > 0 &&
            (emailTextField.text?.characters.count)! > 0 {
            enableLoginButton()
            
        } else {
            disableLoginButton()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil {
            return
        }
        
        switch segue.identifier! {
        case "Login-SignUp":
            let signUpViewController = segue.destination as! SignUpViewController
            signUpViewController.setEmail(email: emailTextField.text)
            signUpViewController.setPassword(password: passwordTextField.text)
            break
            
        default:
            return
        }
    }
    
    func setEmail(email: String?) {
        passedEmail = email
    }
    
    func setPassword(password: String?) {
        passedPassword = password
    }
    
    private func isValidEmail() -> Bool {
        let text = emailTextField.text  // TODO: Improve e-mail validity, currently hard-coded
        return text != nil && (text?.contains("@"))! && (doesEmailExist() || text! == "email@email.com")
    }
    
    private func isValidPassword() -> Bool {
        let text = passwordTextField.text   // TODO: Improve password validity
        return text != nil && (text?.characters.count)! > 3 && (isPasswordValidForEmail() || text! == "password")
    }
    
    private func doesEmailExist() -> Bool {
        // TODO: Put some backend here
        return false
    }
    
    private func isPasswordValidForEmail() -> Bool {
        // TODO: Put some backend here
        return false
    }
    
    private func alertInvalidLogin(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func disableLoginButton() -> Void {
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
    }
    
    private func enableLoginButton() -> Void {
        loginButton.isEnabled = true
        loginButton.alpha = 1
    }
}

extension LoginViewController : UITextFieldDelegate {
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField || textField == passwordTextField {
            textField.resignFirstResponder()
            loginButtonClicked(1 as AnyObject)
            return false
        }
        loginButtonClicked(1 as AnyObject)
        return true
    }
    

}
