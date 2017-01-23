//
//  SignUpToLoginSegue.swift
//  CourtFinder
//
//  Created by Christian Morte on 1/2/17.
//  Copyright © 2017 Christian Morte. All rights reserved.
//

import Foundation
import UIKit

class SignUpToLoginSegue : UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let secondVCView = self.source.view as UIView!
        let firstVCView = self.destination.view as UIView!
        
        let screenHeight = UIScreen.main.bounds.size.height
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(firstVCView!, belowSubview: secondVCView!)
        firstVCView?.frame = (firstVCView?.frame.offsetBy(dx: 0.0, dy: screenHeight))!
        
        // Animate the transition.
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            secondVCView?.frame = ((secondVCView?.frame)?.offsetBy(dx: 0.0, dy: screenHeight))!
            
        }) { (Finished) -> Void in
            self.source.dismiss(animated: false, completion: nil)
        }
    }
}
