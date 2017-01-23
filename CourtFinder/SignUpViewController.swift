//
//  SignUpViewController.swift
//  CourtFinder
//
//  Created by Christian Morte on 1/2/17.
//  Copyright © 2017 Christian Morte. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController : UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    // Email and password fields passed in from login screen
    var passedEmail: String? = nil
    var passedPassword: String? = nil
    
    // MARK: - Override vars
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        NSLog("unwind to sign up screen")
    }
    
    func setEmail(email: String?) {
        passedEmail = email
    }
    
    func setPassword(password: String?) {
        passedPassword = password
    }
}
