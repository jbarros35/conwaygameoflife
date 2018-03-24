//
//  ViewController.swift
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit

class ViewController:  UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    
    var gameLogic:ConwayGame?
    
    // start pause button
    @IBOutlet weak var controlButton: UISwitch!
    
    var timer:Timer?
    
    var squareButtons:[SquareButton] = []

    func initializeBoard() {
        gameLogic = ConwayGame()
        gameLogic?.worldSize = 100
        gameLogic?.gameStatus = .STOPPED
        if var world = gameLogic?.world {
            let worldSize = gameLogic!.worldSize
            for row in 0 ..< worldSize {
                var line:[SquareButton] = []
                for col in 0 ..< worldSize {
                    
                    let square: SquareButton = buttonSquare(row: row, col: col, frameWidth: self.myView.frame.width, worldSize: worldSize).squareButton
                    
                    self.myView.addSubview(square)
                    self.squareButtons.append(square)
                    line.append(square)
                }
                // append line of squares to game
                world.append(line)
            }
            gameLogic?.world = world
        }
    }
    
    struct buttonSquare {
        var row: Int
        var col: Int
        var frameWidth: CGFloat
        var worldSize: Int
        var squareButton: SquareButton {
            get {
                let square = Square(row: row, col: col)
                let squareSize:CGFloat =  frameWidth / 20.0 //CGFloat(worldSize)
                let squareButton = SquareButton(squareModel: square, squareSize: squareSize, squareMargin1: 1.0);
                squareButton.setTitleColor(UIColor.darkGray, for: .normal)
                squareButton.addTarget(self, action: #selector(ViewController.squareButtonPressed(_:)), for: .touchDown) //fix onTapGesture(gesture:)
                return squareButton
            }
        }
    }
    
    func setupGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(ViewController.handlePinchGesture(recognizer:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(sender:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        self.view.addGestureRecognizer(panGesture)
    }
   
    @objc func draggedView(sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        myView.center = CGPoint(x: myView.center.x + translation.x, y: myView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }

    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        myView.transform = (myView.transform).scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
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
                self.gameLogic?.gameStatus = .PAUSED
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
        if(button.square.live) {
            button.backgroundColor = .white
        } else {
            button.backgroundColor = .black
        }
        gameLogic?.toggleCell(line: button.square.row, col: button.square.col)
    }

    func resetBoard() {
        // iterates through each button and resets the text to the default value
        for squareButton in self.squareButtons {
            squareButton.backgroundColor = .white
        }
    }

    func startNewGame() {
        //start new game
        if let game = self.gameLogic {
            if game.getCurrentSize() > 0 {
                if let status = game.gameStatus {
                    switch status {
                    case .RUNNING:
                        self.gameLogic?.gameStatus = .PAUSED
                        break
                    case .STOPPED:
                        self.gameLogic?.gameStatus = .RUNNING
                        runTimer()
                    case .OVER:
                        controlButton.setOn(false, animated: false)
                        self.timer?.invalidate()
                    case .STABLE:
                        self.gameLogic?.gameStatus = .RUNNING
                        runTimer()
                    case .PAUSED:
                        self.gameLogic?.gameStatus = .RUNNING
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
            self.gameLogic?.gameStatus = .RUNNING
            runTimer()
        }
    }
    // REMARK: runs new generation while is RUNNING
    func runTimer() {
            self.timer = Timer.scheduledTimer(
                timeInterval: 0.8, target: self, selector: #selector(ViewController.advanceGeneration),
                userInfo: nil, repeats: true)
            self.gameLogic?.gameStatus = .RUNNING
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        // self.board = Board(size: BOARD_SIZE)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeBoard()
        setupGestureRecognizer()
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        alert.view.setNeedsLayout()
        self.present(alert, animated: true, completion: nil)
    }
    
}

