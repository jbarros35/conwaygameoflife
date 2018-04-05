//
//  AboutViewController.swift
//  ConwayPrj
//
//  Created by Jose on 04/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var topicsCount = 0
    var topics: [AnyObject]?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "aboutCell", for: indexPath as IndexPath) as! AboutViewCell
        
        if let topic = topics {

            // load dictionary from json
            let topicDictionary = topic[indexPath.row] as! NSDictionary
            let title = topicDictionary.object(forKey: "title") as! String
            let text = topicDictionary.object(forKey: "text") as! String
            myCell.setCellContents(title: title, text: text, imageData: nil)
            if let topicItem = topicDictionary.object(forKey: "topic") as? String {
                
                /*
                let imageUrl:NSURL = NSURL(string: imageUrlString)!
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:myCell.frame.size.width, height:myCell.frame.size.height))
                    
                    DispatchQueue.main.async {
                        
                        let image = UIImage(data: imageData as Data)
                        imageView.image = image
                        imageView.contentMode = UIViewContentMode.scaleAspectFit
                        
                        myCell.addSubview(imageView)
                    }
                }
                */
            }
            
            
        }
            
        return  myCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        /*myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView!.dataSource = self
        myCollectionView!.delegate = self
        myCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "aboutCell")
        myCollectionView!.backgroundColor = UIColor.white
        self.view.addSubview(myCollectionView!)*/
        spinner.startAnimating()
        loadListOfImages()
    }
    
    func loadListOfImages()
    {
        // Send HTTP GET Request
        
        // Define server side script URL
        let scriptUrl = "https://conwaygameios.herokuapp.com/about"
        // let scriptUrl = "http://localhost:3000/about"

        // Create NSURL Ibject
        let myUrl = URL(string: scriptUrl);
        
        // Creaste URL Request
        var request = URLRequest(url:myUrl!)
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                MessagesHelper.showStandardMessage(reference: self, title: "Error", message: "Error accessing internet, please check your connection.")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoArray = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray {
                    
                    self.topics = convertedJsonIntoArray as [AnyObject]
                    
                    DispatchQueue.main.async {
                        self.myCollectionView!.reloadData()
                        self.spinner.stopAnimating()
                        self.topicsCount = (self.topics?.count)!
                    }
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    
}
