//
//  File.swift
//  ConwayPrj
//
//  Created by Jose on 31/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation
import UIKit

class MissionViewController: GameViewController {
    
    var missions: MissionsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MessagesHelper.showStandardMessage(reference: self, title: "Mission 1", message: "You can play several challenging missions, every mission accomplished will send you the next. If you want stop hold screen for 1 second or just back.")
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
                    MessagesHelper.showYesNo(reference: self, title: "Game is paused!", message: "Do you want to restart mission or continue?", callbackYes: { action in
                        self.restartGame()
                    }, callbackNo: { action in
                        self.runTimer()
                    }, buttonText: ["Restart", "Continue"])
                case .OVER:
                    // controlButton.setOn(false, animated: false)
                    MessagesHelper.showStandardMessage(reference: self, title: "Game is over!", message: "The game terminated, all creatures are dead.")
                    self.timer?.invalidate()
                default:
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    // REMARK: runs new generation while is RUNNING
    func runTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self, selector: #selector(MissionViewController.advanceGeneration),
            userInfo: nil, repeats: true)
        self.gameLogic?.changeStatus(status: .RUNNING)
    }
    
    // REMARK: run generation and update status in the view
    @objc func advanceGeneration() {
        if let status = self.gameLogic?.gameStatus {
            switch status {
            case .RUNNING:
                self.gameLogic?.runGeneration()
            case .OVER:
                self.collectionView?.reloadData()
                MessagesHelper.showStandardMessage(reference: self, title: "Mission is over!", message: "The missions goals weren't accomplished, do you want to try again?")
                self.timer?.invalidate()
            case .STABLE:
                self.collectionView?.reloadData()
                MessagesHelper.showStandardMessage(reference: self, title: "Game is stopped!", message: "The game isn't evolving anymore and you must put new creatures in the world.")
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
    
    @objc override func longPressed(sender: UILongPressGestureRecognizer)
    {
        MessagesHelper.showStartCancel(reference: self, title: "Start Game", message: "Are you ready to start?", callback: { action in
            self.startNewGame()
        })
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
                    MessagesHelper.showStandardMessage(reference: self, title: "Game isn't valid!", message: "Select some cells to start the game.")
                } else {
                    // controlButton.setOn(false, animated: false)
                    MessagesHelper.showStandardMessage(reference: self, title: "Empty World!", message: "Game is over, please restart")
                }
            }
        } else {
            self.gameLogic?.changeStatus(status: .RUNNING)
            runTimer()
        }
    }
    
    // REMARK: restart mission
    func restartGame() {
        self.timer?.invalidate()
        gameLogic = ConwayGame(worldSize: worldSize)
        gameLogic?.changeStatus(status: .STOPPED)
        self.collectionView?.reloadData()
        self.collectionView?.setNeedsDisplay()
    }
}
