//
//  AccountController.swift
//  ConwayPrj
//
//  Created by Jose on 05/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CreateAccountController: UIViewController {
    
    @IBOutlet weak var passphraseTxt: UITextField!
    @IBOutlet weak var publickeyTxt: UITextField!
    @IBOutlet weak var privateKeyTxt: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func passphraseChanged(_ sender: Any) {
        checkMaxLength(textField: passphraseTxt, maxLength: 16)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        createButton.addTarget(self, action: #selector(createAccount(sender:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save(sender:)), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyAccountData(sender:)), for: .touchUpInside)
        getAccount()
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    // REMARK: load account from Core Data
    func getAccount() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                // print(data.value(forKey: "publickey") as! String)
                self.publickeyTxt.text = data.value(forKey: "publickey") as? String
                self.privateKeyTxt.text = data.value(forKey: "privatekey") as? String
                self.createButton.isEnabled = false
                self.copyButton.isEnabled = true
                self.saveButton.isEnabled = false
                self.passphraseTxt.isEnabled = false
            }
        } catch {
            print("Failed")
        }
    }
    
    // REMARK: copy public and private key to clip board
    @objc func copyAccountData(sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = "Conway Game Account: \n Public key: \(publickeyTxt.text!) \n private key: \(privateKeyTxt.text!) \n keep the data with you and your passphrase, so you can retrive your data in case of wipe your cellphone or retrieving for another device."
        MessagesHelper.showStandardMessage(reference: self, title: "Copy and save", message: "Your public and private key were copied successfully, paste inside your email or notes and save it.")
    }
    
    // REMARK: save account into Core data
    @objc func save(sender: UIButton) {
        let newAccount = NSEntityDescription.insertNewObject(forEntityName: "Account", into: context) as! Account
        newAccount.setValue(privateKeyTxt.text, forKey: "privatekey")
        newAccount.setValue(publickeyTxt.text, forKey: "publickey")
        do {
            try context.save()
        } catch {
            MessagesHelper.showStandardMessage(reference: self, title: "Error!", message: "Sorry, we couldn't save your data try again later.")
            return
        }
        self.saveButton.isEnabled = false
        MessagesHelper.showStandardMessage(reference: self, title: "Sucess!", message: "Your account was saved successfully, all your progress will be saved on it, copy your public and private key safe with you in case of wipe cellphone you wouldn't lose your account.")
    }
    
    // REMARK: invoke service for creating new account.
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
    
    // REMARK: after calling service we get the return async
    func callback(accountData: [String: Any]?, error: Error?) {
        if let errorMsg = error {
            MessagesHelper.showStandardMessage(reference: self, title: "Error!", message: errorMsg.localizedDescription)
            return
        }
        if let jsondata = accountData {
            DispatchQueue.main.async {
                self.publickeyTxt.text = jsondata["address"] as? String
                self.privateKeyTxt.text = jsondata["privateKey"] as? String
                self.createButton.isEnabled = false
                self.copyButton.isEnabled = true
                self.saveButton.isEnabled = true
                MessagesHelper.showStandardMessage(reference: self, title: "Account created", message: "Your account was created with success, hit save button and enjoy the game. Your progression will be saved.")
            }
        }
    }
}
