//
//  SquareCell.swift
//  ConwayPrj
//
//  Created by Jose on 25/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class SquareCell: UICollectionViewCell {
    
    var squareSize:CGFloat = 0.0
    var squareMargin:CGFloat = 0.0
    var square:Square?
    
    func setVars(squareModel:Square, squareSize:CGFloat, squareMargin1:CGFloat) {
        // super.init(frame: squareFrame)
        self.square = squareModel
        self.squareSize = squareSize
        self.squareMargin = squareMargin1
        // let x = CGFloat(self.square!.col) * (squareSize + squareMargin1)
        // let y = CGFloat(self.square!.row) * (squareSize + squareMargin1)
        // self.squareFrame = CGRect(x:x, y:y, width:squareSize, height:squareSize)
        // self.backgroundColor = squareModel.live ? .black : .white
        self.layer.borderWidth = 0.8
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func change(_ state:Bool) {
        self.backgroundColor = state ? .black : .white
        square!.live = state
    }
    
}
