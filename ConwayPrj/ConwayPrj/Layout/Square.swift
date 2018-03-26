//
//  Square.swift
//  ConwayPrj
//
//  Created by Jose on 22/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

class Square {
    
    let row:Int
    let col:Int
    
    var live:Bool = false
    
    // give these default values that we will re-assign later with each new game
    //var numNeighboringMines = 0
    //var isMineLocation = false
    //var isRevealed = false
    init(row:Int, col:Int) {
        //store the row and column of the square in the grid
        self.row = row
        self.col = col
    }
}
