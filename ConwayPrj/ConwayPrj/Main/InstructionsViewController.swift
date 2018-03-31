//
//  InstructionsViewController.swift
//  ConwayPrj
//
//  Created by Jose on 30/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class InstructionsViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var spinner: UIActivityIndicatorView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        self.spinner  = UIActivityIndicatorView()
        self.spinner.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        self.spinner.activityIndicatorViewStyle = .gray
        self.spinner.hidesWhenStopped = true
        self.view.addSubview(spinner)
        self.spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadView()
        // DispatchQueue.global(qos: .background).async {
            let url = "https://conwaygameios.herokuapp.com"
            DispatchQueue.main.async {
                print("start loading")
                let myURL = URL(string: url)
                let myRequest = URLRequest(url: myURL!)
                self.webView.load(myRequest)
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
            self.removeLoader()
        //}
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            print("remove loader")
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
}
