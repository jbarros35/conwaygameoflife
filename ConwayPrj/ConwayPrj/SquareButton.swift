//
//  SquareButton.swift
//  ConwayPrj
//
//  Created by Jose on 22/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class SquareButton : UIButton {
    
    var squareSize:CGFloat
    var squareMargin:CGFloat
    var square:Square
    
    init(squareModel:Square, squareSize:CGFloat, squareMargin1:CGFloat) {
        self.square = squareModel
        self.squareSize = squareSize
        self.squareMargin = squareMargin1
        let x = CGFloat(self.square.col) * (squareSize + squareMargin1)
        let y = CGFloat(self.square.row) * (squareSize + squareMargin1)
        let squareFrame = CGRect(x:x, y:y, width:squareSize, height:squareSize)
        super.init(frame: squareFrame)
        self.backgroundColor = squareModel.live ? .black : .white
        self.layer.borderWidth = 0.8
        self.layer.borderColor = UIColor.black.cgColor
    }

    func change(_ state:Bool) {
        self.backgroundColor = state ? .black : .white
        square.live = state
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
