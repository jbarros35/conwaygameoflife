//
//  MissionsModel.swift
//  ConwayPrj
//
//  Created by Jose on 01/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

enum MissionTypes {
    case MissionTurns((Int?) -> (Bool)) // targets on turns max or min generations
    case MissionEnemyCells((Int?) -> (Bool)) // target how many enemy cells are alive
    case MissionPlayerCells((Int?) -> (Bool)) // target how many player cells are alive
}

class MissionsModel {
    
    var maxMoves: Int?
    var playerCells: Int?
    var enemyCells: Int?
    var generationsCount: Int?
    var missionFailed: Bool?
    var missionRules: [(MissionTypes, [Int])]?
    
    init (maxMoves: Int = 0, playerCells: Int = 0, enemyCells: Int = 0, generationsCount: Int = 0, missionFailed: Bool = false, missionRules: [(MissionTypes, [Int])] = []) {
        self.maxMoves = maxMoves
        self.playerCells = playerCells
        self.enemyCells = enemyCells
        self.generationsCount = generationsCount
        self.missionFailed = missionFailed
        self.missionRules = missionRules
    }
    
    //REMARK: process mission rules, UPDATE status in missions array
    func processRules() {
        var results: [Bool] = []
        guard let rules = missionRules else {
            fatalError("Mission rules weren't set.")
        }
        for (_, tuple) in rules.enumerated() {
            let missionType = tuple.0
            let param = tuple.1
            switch missionType {
            case .MissionTurns(let operation):
                results.append(operation(param[0]))
            case .MissionEnemyCells(let operation):
                results.append(operation(param[0]))
            case .MissionPlayerCells(let operation):
                results.append(operation(param[0]))
            }
        }
        //consolidate results
        self.missionFailed = results.reduce(true, {$0 && $1})
    }
}

class Mission1: MissionsModel {
    
    // current turns are not greater than target turn
    lazy var rule1 = MissionTypes.MissionTurns({ [unowned self] in
        if let turns = self.generationsCount {
            if let current =  $0, turns > current {
                return false
            }
        }
        return true
    })
    
}
