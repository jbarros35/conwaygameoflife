//
//  FreePlayViewController
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit

let reuseIdentifier = "customCell"

extension FreePlayViewController : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! SquareCell
            if let cellState = self.gameLogic?.getCellAt(row: indexPath.section, col: indexPath.row) {
                cell.live = cellState
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! SquareCell
            if let cellState = self.gameLogic?.getCellAt(row: indexPath.section, col: indexPath.row) {
                cell.live = cellState
            }
        }
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
        self.collectionView?.prefetchDataSource = self

        gameLogic = ConwayGame(worldSize: worldSize)
        gameLogic?.changeStatus(status: .STOPPED)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        if !(self.collectionView?.visibleCells.isEmpty)! {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
            longPressRecognizer.minimumPressDuration = 3
            self.view.addGestureRecognizer(longPressRecognizer)
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(gesture:)))
            self.view.addGestureRecognizer(pinchRecognizer)
        }
    }
    
    // REMARK: click on cell and change it state
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
        if let cellState = gameLogic?.getCellAt(row: indexPath.section, col: indexPath.row) {
            cell.change(!cellState)
            gameLogic?.toggleCell(line: indexPath.section, col: indexPath.row)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return worldSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return worldSize
    }
    // REMARK: load cells into collectionView
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SquareCell
        if let cellState = self.gameLogic?.getCellAt(row: indexPath.section, col: indexPath.row) {
            cell.live = cellState
        }
        return cell
    }
 
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
                updateGrid()
            case .OVER:
                updateGrid()
                showMessage(title: "Game is over!", message: "The game terminated, all creatures are dead.")
                self.timer?.invalidate()
            case .STABLE:
                updateGrid()
                showMessage(title: "Game is stopped!", message: "The game isn't evolving anymore and you must put new creatures in the world.")
                // controlButton.setOn(false, animated: false)
                self.timer?.invalidate()
            case .STOPPED:
                self.timer?.invalidate()
            case .PAUSED:
                self.timer?.invalidate()
            }
            
        }
    }

    func updateGrid() {
        if let currentGeneration = self.gameLogic?.currentGeneration {
            // clean previous history
            for oldCell in (self.gameLogic?.staleGeneration)! {
                if let cell = self.collectionView?.cellForItem(at: IndexPath(row: oldCell.0, section: oldCell.1)) as? SquareCell {
                    // erase it!
                    cell.change(false)
                }
            }
            for cellW in currentGeneration {
                // print("update: \(currentGeneration)")
                if let cell = self.collectionView?.cellForItem(at: IndexPath(row: cellW.0, section: cellW.1)) as? SquareCell {
                    print(cell.live)
                    if let state = self.gameLogic?.getCellAt(row: cellW.0, col: cellW.1) {
                        cell.change(state)
                    }
                }
            }
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
                timeInterval: 0.8, target: self, selector: #selector(FreePlayViewController.advanceGeneration),
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
        print("longpressed")
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

