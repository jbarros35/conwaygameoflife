//
//  ViewController.swift
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit

class ViewController:  UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movesLabel: UILabel!
    // @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myView: UICollectionView!
    
    var gameLogic:ConwayGamePtcl?
    
    // start pause button
    @IBOutlet weak var controlButton: UISwitch!
    
    var timer:Timer?

    func initializeBoard() {
        gameLogic = ConwayGame()
        gameLogic?.worldSize = 100
        gameLogic?.changeStatus(status: .STOPPED)
        if var world = gameLogic?.world {
            self.myView.allowsMultipleSelection = false
            let worldSize = gameLogic!.worldSize
            var buttonCount = 0
            for row in 0 ..< worldSize {
                var line:[SquareCell] = []
                for col in 0 ..< worldSize {
                    let squareButton: SquareCell = buttonSquare(row: row, col: col, frameWidth: self.myView.frame.width, worldSize: worldSize).squareButton
                    // squareButton.addTarget(self, action: #selector(ViewController.squareButtonPressed(_:)), for: .touchUpInside)
                    squareButton.tag = buttonCount
                    self.myView.addSubview(squareButton)
                    line.append(squareButton)
                    buttonCount = buttonCount + 1
                }
                // append line of squares to game
                // world.append(line)
            }
            gameLogic?.world = world
        }
    }
    
    struct buttonSquare {
        var row: Int
        var col: Int
        var frameWidth: CGFloat
        var worldSize: Int
        var squareButton: SquareCell {
            get {
                let square = Square(row: row, col: col)
                let squareSize:CGFloat =  frameWidth / 20 // CGFloat(worldSize)
                let squareButton = SquareCell()
                squareButton.square = square
                squareButton.setVars(squareModel: square, squareSize: squareSize, squareMargin1: 1.0);
                // squareButton.setTitleColor(UIColor.darkGray, for: .normal)
                return squareButton
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gameLogic?.worldSize ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = myView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! SquareCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        cell.squareMargin =  1.0
        
        cell.contentView.layer.cornerRadius = 2.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
    }
    
    // REMARK: add all gestures supported
    func setupGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(ViewController.handlePinchGesture(recognizer:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(sender:)))
        panGesture.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        self.view.addGestureRecognizer(panGesture)
    }

    
    // REMARK: controls pan view
    @objc func draggedView(sender:UIPanGestureRecognizer){
        if ((sender.state != UIGestureRecognizerState.ended) &&
            (sender.state != UIGestureRecognizerState.failed)) {
            let translation = sender.translation(in: self.view)
            myView.center = CGPoint(x: myView.center.x + translation.x, y: myView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
            // sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }

    // REMARK: controls pinch gesture
    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        myView.transform = (myView.transform).scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
        myView.reloadData()
    }
    
    @objc func squareButtonPressed(_ sender: SquareButton) {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .PAUSED:
                // we change button state
                changeButton(button: sender)
            case .STOPPED:
                // we change button
                changeButton(button: sender)
            case .RUNNING:
                controlButton.setOn(false, animated: false)
                // we just pause
                self.gameLogic?.changeStatus(status: .PAUSED)
            case .STABLE:
                changeButton(button: sender)
                controlButton.setOn(false, animated: false)
                self.timer?.invalidate()
            case .OVER:
                controlButton.setOn(false, animated: false)
                showMessage(title: "Game is over!", message: "The game terminated, all creatures are dead.")
                self.timer?.invalidate()
            }
        }
    }
    
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
            case .OVER:
                controlButton.setOn(false, animated: false)
                showMessage(title: "Game is over!", message: "The game terminated, all creatures are dead.")
                self.timer?.invalidate()
            case .STABLE:
                showMessage(title: "Game is stopped!", message: "The game isn't evolving anymore and you must put new creatures in the world.")
                controlButton.setOn(false, animated: false)
                self.timer?.invalidate()
            case .STOPPED:
                self.timer?.invalidate()
            case .PAUSED:
                self.timer?.invalidate()
            }
            if let generationsCount = gameLogic?.generations {
                movesLabel.text = "\(String(describing: generationsCount))"
            }
        }
    }
    
    @IBAction func newGamePressed() {
        self.startNewGame()
    }
    
    func changeButton(button: SquareButton) {
        print("Button tag: \(button.tag)")
        if(button.square.live) {
            button.backgroundColor = .white
        } else {
            button.backgroundColor = .black
        }
        gameLogic?.toggleCell(line: button.square.row, col: button.square.col)
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
                        controlButton.setOn(false, animated: false)
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
                    controlButton.setOn(false, animated: false)
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
        // self.board = Board(size: BOARD_SIZE)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.myView.delegate = self
        self.initializeBoard()
        setupGestureRecognizer()
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

