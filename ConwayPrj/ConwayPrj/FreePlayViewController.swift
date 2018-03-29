//
//  FreePlayViewController
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit

let reuseIdentifier = "customCell"

extension FreePlayViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return worldSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return worldSize
    }
    
}

class FreePlayViewController: UICollectionViewController {
    
    var gameLogic:ConwayGamePtcl?
    let worldSize = 30
    var timer:Timer?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
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
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(gesture:)))
            self.view.addGestureRecognizer(pinchRecognizer)
        }
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
    
    // REMARK: click on cell and change it state
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SquareCell {
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
                    showMessage(title: "Game is paused!", message: "You'd tap on the screen select your cells, when you are ready hold tap for 1 second to continue.")
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
    
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
       
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
            case .OVER:
                self.collectionView?.reloadData()
                showMessage(title: "Game is over!", message: "The game terminated, all creatures are dead.")
                self.timer?.invalidate()
            case .STABLE:
                self.collectionView?.reloadData()
                showMessage(title: "Game is stopped!", message: "The game isn't evolving anymore and you must put new creatures in the world.")
                self.timer?.invalidate()
            case .STOPPED:
                self.collectionView?.reloadData()
                self.timer?.invalidate()
            case .PAUSED:
                self.collectionView?.reloadData()
                self.timer?.invalidate()
            }
            self.collectionView?.reloadData()
        }
        
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
            self.gameLogic?.changeStatus(status: .RUNNING)
            runTimer()
        }
    }
    
    // REMARK: runs new generation while is RUNNING
    func runTimer() {
            self.timer = Timer.scheduledTimer(
                timeInterval: 1.0, target: self, selector: #selector(FreePlayViewController.advanceGeneration),
                userInfo: nil, repeats: true)
            self.gameLogic?.changeStatus(status: .RUNNING)
    }

    @objc private func pinchHandler(gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            switch gesture.state {
            case .changed:
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: gesture.scale, y: gesture.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                gesture.scale = 1
            case .ended:
                // Nice animation to scale down when releasing the pinch.
                // OPTIONAL
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity
                })
            default:
                return
            }
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        showStartMessage(title: "Start Game", message: "Are you ready for begin?")
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
    
    func showStartMessage(title: String, message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Start", style: UIAlertActionStyle.default, handler: { action in
            self.startNewGame()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        alert.view.setNeedsLayout()
        self.present(alert, animated: true, completion: nil)
    }
    
}

