//
//  GameController.swift
//  ConwayPrj
//
//  Created by Jose on 20/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

// MARK:- UICollectionViewDataSource Delegate
extension GameController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return worldSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return worldSize
    }
    
    // REMARK: load cells into collectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SquareCell
        
        // get World reference
        if let cellWorldState = self.gameLogic?.getCellAt(row: indexPath.section, col: indexPath.row) {
         cell.change(cellWorldState)
         }
        return cell
    }
    
    // REMARK: select a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SquareCell {
            if let status = self.gameLogic?.gameStatus {
                switch status {
                case .PAUSED, .OVER:
                    // we change button state
                    changeButton(cell: cell, indexPath: indexPath)
                case .STOPPED:
                    // we change button
                    changeButton(cell: cell, indexPath: indexPath)
                case .RUNNING:
                    // we just pause
                    self.gameLogic?.changeStatus(status: .PAUSED)
                    MessagesHelper.showStandardMessage(reference: self, title: "Game is paused!", message: "You'd tap on the screen select your cells, when you are ready hold tap for 1 second to continue.")
                case .STABLE:
                    changeButton(cell: cell, indexPath: indexPath)
                    self.timer?.invalidate()
                }
            }
        }
    }
}

class GameController: UIViewController {
    
    var timer: Timer?
    var gameLogic: ConwayGamePtcl?
    let standardCellSize = (20.0, 20.0)
    let worldSize = 30
    let reuseIdentifier = "customCell"
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var generationsBar: UIProgressView!
    @IBOutlet var cellCountLbl: UILabel!
    @IBOutlet var button: UIButton!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameLogic = ConwayGame(worldSize: worldSize)
        gameLogic?.changeStatus(status: .STOPPED)
        self.generationsBar.setProgress(0.0, animated: true)
    }
    
    func reload() {
        gameLogic = ConwayGame(worldSize: worldSize)
        gameLogic?.changeStatus(status: .STOPPED)
        self.generationsBar.setProgress(0.0, animated: true)
        button.setTitle("Start", for: .normal)
    }

    // REMARK: change the state inside World referenced.
    func changeButton(cell: SquareCell, indexPath: IndexPath) {
        if cell.live ?? true {
            cell.change(false)
        } else {
            cell.change(true)
        }
        
        if gameLogic?.getCellAt(row: indexPath.row, col: indexPath.section) != nil {
            gameLogic?.toggleCell(line: indexPath.section, col: indexPath.row)
        }
    }
    
    @IBAction func startGame(_ sender: UIButton) {
        //start new game
        if var game = self.gameLogic {
            if game.getCurrentSize() > 0 {
                if let status = game.gameStatus {
                    switch status {
                    case .RUNNING:
                        self.gameLogic?.changeStatus(status: .PAUSED)
                        button.setTitle("Start", for: .normal)
                        break
                    case .STOPPED:
                        self.gameLogic?.changeStatus(status: .RUNNING)
                        button.setTitle("Pause", for: .normal)
                        runTimer()
                    case .OVER:
                        self.timer?.invalidate()
                        button.setTitle("Restart", for: .normal)
                    case .STABLE:
                        self.gameLogic?.changeStatus(status: .RUNNING)
                        button.setTitle("Pause", for: .normal)
                        runTimer()
                    case .PAUSED:
                        button.setTitle("Pause", for: .normal)
                        self.gameLogic?.changeStatus(status: .RUNNING)
                        runTimer()
                    }
                }
            } else {
                if self.gameLogic?.gameStatus != .OVER {
                    MessagesHelper.showStandardMessage(reference: self, title: "Game isn't valid!", message: "Select some cells to start the game.")
                } else {
                    button.setTitle("Pause", for: .normal)
                    reload()
                    runTimer()
                }
            }
        } else {
            self.gameLogic?.changeStatus(status: .RUNNING)
            runTimer()
        }
    }
    
    // REMARK: when view appear
    override func viewDidAppear(_ animated: Bool) {
        if !(self.collectionView?.visibleCells.isEmpty)! {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(gesture:)))
            self.view.addGestureRecognizer(pinchRecognizer)
        }
        MessagesHelper.showStandardMessage(reference: self, title: "Hello!", message: "This is the freeplay of Conway Game, you can set your cells everywhere, when ready to begin just tap start to begin playing.")
    }
    
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
            case .OVER:
                self.collectionView?.reloadData()
                MessagesHelper.showStandardMessage(reference: self, title: "Game is over!", message: "The game terminated, all creatures are dead.")
                self.timer?.invalidate()
                button.setTitle("Restart", for: .normal)
            case .STABLE:
                self.collectionView?.reloadData()
                button.setTitle("Start", for: .normal)
                MessagesHelper.showStandardMessage(reference: self, title: "Game is stopped!", message: "The game isn't evolving anymore and you must put new creatures in the world.")
                self.timer?.invalidate()
            case .STOPPED:
                self.collectionView?.reloadData()
                self.timer?.invalidate()
            case .PAUSED:
                self.collectionView?.reloadData()
                self.timer?.invalidate()
            }
            self.generationsBar.setProgress(Float(self.gameLogic!.generations) / 100.0, animated: true)
            self.cellCountLbl.text = "Player Cells: \(self.gameLogic!.getCurrentSize())"
            self.collectionView?.reloadData()
        }
        // it validate history repeatition.
        if let generationsHistory = self.gameLogic?.generationsHistory {
            if generationsHistory.contains("\(self.gameLogic?.currentGeneration ?? [])") {
                self.gameLogic?.gameStatus = .STABLE
            }
        }
    }
    
    // REMARK: runs new generation while is RUNNING
    func runTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self, selector: #selector(GameController.advanceGeneration),
            userInfo: nil, repeats: true)
        self.gameLogic?.changeStatus(status: .RUNNING)
    }

    @objc private func pinchHandler(gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            switch gesture.state {
            case .changed:
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                let transform = self.collectionView?.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: gesture.scale, y: gesture.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                self.collectionView?.transform = transform!
                gesture.scale = 1
            case .ended:
                break
            default:
                return
            }
        }
    }
    
 
}
