//
//  AboutViewCell.swift
//  ConwayPrj
//
//  Created by Jose on 04/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class AboutViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageTopic: UIImageView!
    @IBOutlet weak var titleTopic: UILabel!
    @IBOutlet weak var text: UILabel!
    
    func setCellContents(title: String = "", text: String = "", imageData: String?) {
        self.titleTopic.text = title
        self.text.text = text
        self.titleTopic.sizeToFit()
        self.text.sizeToFit()
        guard let imgUrl = imageData else {
            return
        }
        self.imageTopic.image = UIImage(named: imgUrl)
    }
}
