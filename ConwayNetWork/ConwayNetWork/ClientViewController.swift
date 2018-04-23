//
//  ViewController.swift
//  ConwayNetWork
//
//  Created by Jose on 23/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit
import Starscream

class ClientViewController: UIViewController {

    @IBOutlet var idLbl: UILabel!
    @IBOutlet var dataTxt: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var connectionBtn: UIButton!
    var socket: WebSocket?
    var clientUUID: String?
    
    @IBAction func sendData(_ sender: UIButton) {
        let json = """
        {
          "id": "\(self.clientUUID!)",
          "event": "chat",
          "data" : "\(String(describing: self.dataTxt.text!))",
          "date" : "\(Date())"
        }
        """.data(using: .utf8)!
        socket?.write(data: json)
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        socket?.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        connect()
    }
    
    struct Event: Decodable {
        let id: String
        let event: String
        let data: String?
        let date: String?
        let action: String?
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
                // socket?.delegate = self
                socket?.connect()
            }
            //websocketDidConnect
            socket?.onConnect = {
                print("websocket is connected")
            }
            //websocketDidDisconnect
            socket?.onDisconnect = { (error: Error?) in
                print("websocket is disconnected: \(error?.localizedDescription)")
            }
            //websocketDidReceiveMessage
            socket?.onText = { (text: String) in
                print("got some text: \(text)")
                // convert String to data for parsing
                if let data = text.data(using: .utf8) {
                    guard let event = try? JSONDecoder().decode(Event.self, from: data) else {
                        print("Error: Message format not known")
                        return
                    }
                    // new client id
                    if event.event == "client_id" {
                        self.idLbl.text = event.id
                        self.clientUUID = event.id
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

