//
//  GameViewController.swift
//  ConwayPrj
//
//  Created by Jose on 01/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

let reuseIdentifier = "customCell"

extension GameViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return worldSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return worldSize
    }
    
    // REMARK: load cells into collectionView
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SquareCell
        
        // get World reference
        if let cellWorldState = self.gameLogic?.getCellAt(row: indexPath.section, col: indexPath.row) {
            cell.change(cellWorldState)
        }
        return cell
    }
}

protocol GameView {
    var playerCellsCount: Int {get set}
    var gameLogic:ConwayGamePtcl? {get set}
    var timer:Timer? {get set}
    var worldSize: Int {get set}
    func changeButton(cell: SquareCell, indexPath: IndexPath)
    func longPressed(sender: UILongPressGestureRecognizer)
}

class GameViewController: UICollectionViewController, GameView {
    
    var playerCellsCount: Int = 0
    var worldSize: Int = 30
    var gameLogic: ConwayGamePtcl?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.isPrefetchingEnabled = false
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        gameLogic = ConwayGame(worldSize: worldSize)
        gameLogic?.changeStatus(status: .STOPPED)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !(self.collectionView?.visibleCells.isEmpty)! {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
            longPressRecognizer.minimumPressDuration = 1
            self.view.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    // REMARK: change the state inside World referenced.
    func changeButton(cell: SquareCell, indexPath: IndexPath) {
        if cell.live ?? true {
            playerCellsCount = playerCellsCount - 1
            cell.change(false)
        } else {
            playerCellsCount = playerCellsCount + 1
            cell.change(true)
        }
        
        if gameLogic?.getCellAt(row: indexPath.row, col: indexPath.section) != nil {
            gameLogic?.toggleCell(line: indexPath.section, col: indexPath.row)
        }
    }
    
    // REMARK: MUST be overriden on subclasses
    @objc func longPressed(sender: UILongPressGestureRecognizer) {}
}
