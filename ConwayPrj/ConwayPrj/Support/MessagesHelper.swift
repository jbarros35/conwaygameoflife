//
//  MessagesHelper.swift
//  ConwayPrj
//
//  Created by Jose on 31/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class MessagesHelper {
    
    
    static func showStandardMessage(reference: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.view.setNeedsLayout()
        reference.present(alert, animated: true, completion: nil)
    }
    
    static func showStartCancel(reference: UIViewController, title: String, message: String, callback: @escaping (UIAlertAction)->()) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Start", style: UIAlertActionStyle.default, handler: callback))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        alert.view.setNeedsLayout()
        reference.present(alert, animated: true, completion: nil)
    }
    
}
