//
//  Board.swift
//  ConwayPrj
//
//  Created by Jose on 22/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

class Board {
    let size:Int
    var squares:[[Square]] = [] // a 2d array of square cells, indexed by [row][column]
    
    init(size:Int) {
        self.size = size
        for row in 0 ..< size {
            var squareRow:[Square] = []
            for col in 0 ..< size {
                let square = Square(row: row, col: col)
                squareRow.append(square)
            }
            squares.append(squareRow)
        }
    }
    
    func resetBoard() {
        // assign mines to squares
        for row in 0 ..< size {
            for col in 0 ..< size {
                squares[row][col].live = false
                // self.calculateIsMineLocationForSquare(squares[row][col])
            }
        }
        
    }

}
