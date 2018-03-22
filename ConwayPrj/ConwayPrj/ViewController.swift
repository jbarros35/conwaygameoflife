//
//  ViewController.swift
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import UIKit

class ViewController:  UIViewController {
    
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var movesLabel: UILabel!
    // @IBOutlet weak var timeLabel: UILabel!
    
    // var board:Board
    
    var gameLogic:ConwayGame?
    
    var timer:Timer?
    
    var squareButtons:[SquareButton] = []

    func initializeBoard() {
        // gameLogic?.initWorld()
        gameLogic = ConwayGame()
        if var world = gameLogic?.world {
            let worldSize = gameLogic!.worldSize
            for row in 0 ..< worldSize {
                var line:[SquareButton] = []
                for col in 0 ..< worldSize {
                    // let square = world[row][col]
                    let square = Square(row: row, col: col)
                    let squareSize:CGFloat = self.boardView.frame.width / CGFloat(worldSize)
                    let squareButton = SquareButton(squareModel: square, squareSize: squareSize, squareMargin1: 1.0);
                    squareButton.setTitleColor(UIColor.darkGray, for: .normal)
                    squareButton.addTarget(self, action: #selector(ViewController.squareButtonPressed(_:)), for: .touchUpInside) //fix onTapGesture(gesture:)
                    self.boardView.addSubview(squareButton)
                    self.squareButtons.append(squareButton)
                    line.append(squareButton)
                }
                // append line of squares to game
                world.append(line)
            }
            gameLogic?.world = world
        }
        
    }
    
    @objc func squareButtonPressed(_ sender: SquareButton) {
        if(sender.square.live) {
            sender.backgroundColor = .white
        } else {
            sender.backgroundColor = .black
        }
        gameLogic?.toggleCell(line: sender.square.row, col: sender.square.col)
    }

    func resetBoard() {
        // resets the board with new mine locations & sets isRevealed to false for each square
        // self.gameLogic?.initWorld()
        // iterates through each button and resets the text to the default value
        for squareButton in self.squareButtons {
            squareButton.backgroundColor = .white
        }
    }

    func startNewGame() {
        //start new game
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.gameStatus = .PAUSED
                break
            case .STOPPED:
                self.gameLogic?.gameStatus = .RUNNING
                runTimer()
            case .PAUSED:
                self.gameLogic?.gameStatus = .RUNNING
                runTimer()
            }
        } else {
            // self.resetBoard()
            self.gameLogic?.gameStatus = .RUNNING
            runTimer()
        }
        
    }
    
    func runTimer() {
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.timer = Timer.scheduledTimer(
                timeInterval: 1.0, target: self, selector: #selector(ViewController.advanceGeneration),
                userInfo: nil, repeats: true)
            self.gameLogic?.gameStatus = .RUNNING
        // }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        // self.board = Board(size: BOARD_SIZE)
        // gameLogic = ConwayGame()
        super.init(coder: aDecoder)
    }
    
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
                //print("advance next its running")
            case .STOPPED:
                self.timer?.invalidate()
                //print("stop")
            case .PAUSED:
                self.timer?.invalidate()
                //print("paused game do nothing")
            }
        }
    }
    
    @IBAction func newGamePressed() {
        print("new game");
        self.startNewGame()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeBoard()
        // self.startNewGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

