//
//  ViewController.swift
//  ConwayNetWork
//
//  Created by Jose on 23/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit
import Starscream

// Put this piece of code anywhere you like


extension ClientViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ClientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var idLbl: UILabel!
    @IBOutlet var dataTxt: UITextField!
    @IBOutlet var dataTxtY: UITextField!
    @IBOutlet var nickTxt: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var connectBtn: UIButton!
    @IBOutlet var disconnectBtn: UIButton!
    
    var socket: WebSocket?
    var clientUUID: String?
    var events = [Event]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func connectAction(_ sender: UIButton) {
        connect()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "tableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let event = events[indexPath.row]
        
        cell.idLbl.text = event.nick
        cell.eventLbl.text = event.event
        if let data = event.data {
            cell.dataLbl.text = "\(String(describing: data))"
        }
        if let date = event.date {
            cell.dateLbl.text = date
        }
        return cell
    }
    // REMARK: send moves to server
    @IBAction func sendData(_ sender: UIButton) {
        var data = [[Int]]()
        data = [[Int(self.dataTxt.text ?? "0"), Int(self.dataTxtY.text ?? "0")]] as! [[Int]]
        // yyyyMMdd HH:mm:ss
        let date = Date()
        let json = """
        {
          "id": "\(self.clientUUID!)",
          "action": "move",
          "data" :  \(data),
          "date" : "\(date)"
        }
        """.data(using: .utf8)!
        socket?.write(data: json)
        // update table
        let event = Event(id: self.clientUUID!, nick: self.nickTxt.text!, event: "move", data: data, date: convertDate(date: date))
        self.events.insert(event, at: 0)
        self.tableView.reloadData()
        self.dataTxt.text = nil
        self.dataTxtY.text = nil
    }
    
    // REMARK: format date for better display
    func convertDate(date: Date) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: date)
            return dateString
    }
    
    // REMARK: server sends dates on JS string format
    func convertJSDate(date: String) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatterGet.date(from: date) {
            return convertDate(date: date)
        }
        return nil
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        socket?.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hideKeyboardWhenTappedAround()
    }
    
    struct Event: Decodable {
        let id: String
        let nick: String?
        let event: String
        let data: [[Int]]?
        var date: String?
    }
    
    func connect() {
        socket = WebSocket(url: URL(string: "wss://localhost:443/")!, protocols: [])
        // Set enabled cipher suites to AES 256 and AES 128
         socket?.enabledSSLCipherSuites = [TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384]
        do
        {
            let urlPath     = Bundle.main.path(forResource: "cert", ofType: "der")
            let url         = NSURL.fileURL(withPath: urlPath!)
            let certificateData = try Data(contentsOf: url)
            
            let certificate: SecCertificate =
                SecCertificateCreateWithData(kCFAllocatorDefault, certificateData as CFData)!
            
            var trust: SecTrust?
            let policy = SecPolicyCreateBasicX509()
            socket?.disableSSLCertValidation = true
            let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
            if status == errSecSuccess {
                let key = SecTrustCopyPublicKey(trust!)!;
                let ssl =  SSLCert(key: key)
                socket?.security = SSLSecurity(certs: [ssl], usePublicKeys: true)
                socket?.connect()
            }
            
            //websocketDidConnect
            socket?.onConnect = {
                print("websocket is connected")
                self.connectBtn.isEnabled = false
                self.disconnectBtn.isEnabled = true
                self.dataTxt.isEnabled = true
                self.dataTxtY.isEnabled = true
                self.sendButton.isEnabled = true
            }
            
            //websocketDidDisconnect
            socket?.onDisconnect = { (error: Error?) in
                print("websocket is disconnected: \(error?.localizedDescription)")
                self.connectBtn.isEnabled = true
                self.nickTxt.isEnabled = true
                self.disconnectBtn.isEnabled = false
                self.dataTxt.isEnabled = false
                self.dataTxtY.isEnabled = false
                self.sendButton.isEnabled = false
            }
            
            //websocketDidReceiveMessage
            socket?.onText = { (text: String) in
                print("got some text: \(text)")
                // convert String to data for parsing
                if let data = text.data(using: .utf8) {
                    guard var event = try? JSONDecoder().decode(Event.self, from: data) else {
                        print("Error: Message format not known")
                        return
                    }
                    // new client id
                    if event.event == "client_id" {
                        self.idLbl.text = event.id
                        self.clientUUID = event.id
                        // send nick after getting id
                        let json = """
                            {
                            "id": "\(self.clientUUID!)",
                            "action": "setnick",
                            "value" :  "\(String( describing: self.nickTxt.text!))",
                            "date" : "\(self.convertDate(date: Date()) ?? "")"
                            }
                            """.data(using: .utf8)!
                        self.socket?.write(data: json)
                        self.nickTxt.isEnabled = false
                    } else {
                        if let jsdate = event.date {
                            event.date = self.convertJSDate(date: jsdate)
                        }
                        self.events.insert(event, at: 0)
                        self.tableView.reloadData()
                    }
                }
            }
            //websocketDidReceiveData
            socket?.onData = { (data: Data) in
                print("got some data: \(data.count)")
            }
        }catch let error as NSError
        {
            print(error)
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

