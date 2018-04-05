//
//  NetworkHelper.swift
//  ConwayPrj
//
//  Created by Jose on 05/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class NetworkHelper {
    
    func postURL(url: String, json: [String: Any], callback: @escaping ([String: Any]?, Error?)->())
    {
        // Create NSURL Ibject
        let myUrl = URL(string: url);

        // Creaste URL Request
        var request = URLRequest(url:myUrl!)
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "POST"
        
        // let jsonData : NSData = NSKeyedArchiver.archivedData(withRootObject: json) as NSData JSONSerialization.isValidJSONObject(jsonData)

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                callback([:], error)
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    callback(responseJSON, nil)
                }
                
                if let convertedJsonIntoArray = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                    print(convertedJsonIntoArray)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                callback([:], error)
            }
        }
        task.resume()
    }
    
}
