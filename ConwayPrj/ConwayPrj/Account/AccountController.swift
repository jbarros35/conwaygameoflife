//
//  AccountController.swift
//  ConwayPrj
//
//  Created by Jose on 05/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class AccountController: UIViewController {
    
    @IBOutlet weak var passphraseTxt: UITextField!
    @IBOutlet weak var publickeyTxt: UITextField!
    
    @IBOutlet weak var privateKeyTxt: UITextField!

    @IBOutlet weak var createButton: UIButton!
    
    @IBAction func passphraseChanged(_ sender: Any) {
        checkMaxLength(textField: passphraseTxt, maxLength: 16)
    }
    
    override func viewDidLoad() {
        createButton.addTarget(self, action: #selector(createAccount(sender:)), for: .touchUpInside)
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        // swift 2.0
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    @objc func createAccount(sender: UIButton) {
        guard let passphrase = passphraseTxt.text else {
            
            return
        }
        if passphrase.count <= 5 {
            MessagesHelper.showStandardMessage(reference: self, title: "Error", message: "Please set your passphrase minimum 6 characters and try again.")
            return
        }
        let netWork = NetworkHelper()
        netWork.postURL(url: "https://blockchainjs.herokuapp.com/testerpc/create", json: ["passphrase":passphrase], callback: callback)
    }
    
    func callback(accountData: [String: Any]?, error: Error?) {
        if let errorMsg = error {
            MessagesHelper.showStandardMessage(reference: self, title: "Error!", message: errorMsg.localizedDescription)
        }
        if let jsondata = accountData {
            DispatchQueue.main.async {
                self.publickeyTxt.text = jsondata["address"] as? String
                self.privateKeyTxt.text = jsondata["privateKey"] as? String
            }
        }
    }
}
