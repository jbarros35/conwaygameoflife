//
//  ViewController.swift
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit

let reuseIdentifier = "customCell"

class ViewController: UICollectionViewController {
    
    var gameLogic:ConwayGamePtcl?
    let worldSize = 20
    var timer:Timer?

    func initializeBoard() {
        gameLogic = ConwayGame()
        gameLogic?.worldSize = worldSize
        gameLogic?.changeStatus(status: .STOPPED)
        
        if let collection = self.collectionView {
            if var world = gameLogic?.world {
                for row in 0 ..< worldSize {
                    var line:[SquareCell] = []
                    for col in 0 ..< worldSize {
                        let index = IndexPath(row: row, section: col)
                        if let cell = collection.cellForItem(at: index) {
                            line.append(collection.cellForItem(at: index) as! SquareCell)
                        }
                    }
                    // append line of squares to game
                    world.append(line)
                }
                gameLogic?.world = world
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SquareCell {
            print("You selected cell #\(indexPath.section) \(indexPath.row)!")
            if let status = self.gameLogic?.gameStatus {
                switch status {
                case .PAUSED:
                    // we change button state
                    changeButton(cell: cell, indexPath: indexPath)
                case .STOPPED:
                    // we change button
                    changeButton(cell: cell, indexPath: indexPath)
                case .RUNNING:
                    // controlButton.setOn(false, animated: false)
                    // we just pause
                    self.gameLogic?.changeStatus(status: .PAUSED)
                case .STABLE:
                    changeButton(cell: cell, indexPath: indexPath)
                    // controlButton.setOn(false, animated: false)
                    self.timer?.invalidate()
                case .OVER:
                    // controlButton.setOn(false, animated: false)
                    showMessage(title: "Game is over!", message: "The game terminated, all creatures are dead.")
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    func changeButton(cell: SquareCell, indexPath: IndexPath) {
        cell.backgroundColor = cell.backgroundColor == UIColor.black ? UIColor.white : UIColor.black
        gameLogic?.toggleCell(line: indexPath.section, col: indexPath.row)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return worldSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return worldSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SquareCell
        return cell
    }
   
    @objc func squareButtonPressed(_ sender: SquareButton) {
        
    }
    
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
            case .OVER:
                // controlButton.setOn(false, animated: false)
                showMessage(title: "Game is over!", message: "The game terminated, all creatures are dead.")
                self.timer?.invalidate()
            case .STABLE:
                showMessage(title: "Game is stopped!", message: "The game isn't evolving anymore and you must put new creatures in the world.")
                // controlButton.setOn(false, animated: false)
                self.timer?.invalidate()
            case .STOPPED:
                self.timer?.invalidate()
            case .PAUSED:
                self.timer?.invalidate()
            }
            if let generationsCount = gameLogic?.generations {
                // movesLabel.text = "\(String(describing: generationsCount))"
            }
        }
    }
    
    @IBAction func newGamePressed() {
        self.startNewGame()
    }

    func startNewGame() {
        //start new game
        if let game = self.gameLogic {
            if game.getCurrentSize() > 0 {
                if let status = game.gameStatus {
                    switch status {
                    case .RUNNING:
                        self.gameLogic?.changeStatus(status: .PAUSED)
                        break
                    case .STOPPED:
                        self.gameLogic?.changeStatus(status: .RUNNING)
                        runTimer()
                    case .OVER:
                        // controlButton.setOn(false, animated: false)
                        self.timer?.invalidate()
                    case .STABLE:
                        self.gameLogic?.changeStatus(status: .RUNNING)
                        runTimer()
                    case .PAUSED:
                        self.gameLogic?.changeStatus(status: .RUNNING)
                        runTimer()
                    }
                }
            } else {
                if self.gameLogic?.gameStatus != .OVER {
                    showMessage(title: "Game isn't valid!", message: "Select some cells to start the game.")
                } else {
                    // controlButton.setOn(false, animated: false)
                    showMessage(title: "Empty World!", message: "Game is over, please restart")
                }
            }
        } else {
            // self.resetBoard()
            self.gameLogic?.changeStatus(status: .RUNNING)
            runTimer()
        }
    }
    // REMARK: runs new generation while is RUNNING
    func runTimer() {
            self.timer = Timer.scheduledTimer(
                timeInterval: 0.8, target: self, selector: #selector(ViewController.advanceGeneration),
                userInfo: nil, repeats: true)
            self.gameLogic?.changeStatus(status: .RUNNING)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        if !(self.collectionView?.visibleCells.isEmpty)! {
            //
            print("init board")
            self.initializeBoard()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.view.setNeedsLayout()
        self.present(alert, animated: true, completion: nil)
    }
    
}

