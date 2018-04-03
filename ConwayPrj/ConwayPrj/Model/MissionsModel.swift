//
//  MissionsModel.swift
//  ConwayPrj
//
//  Created by Jose on 01/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

enum MissionType {
    case Turns // targets on turns max or min generations
    case EnemyCells // target how many enemy cells are alive
    case PlayerCells // target how many player cells are alive
}

enum MissionStatus {
    case Failed
    case Running
    case Success
}

class MissionsModel {
    
    var maxMoves: Int?
    var playerCells: Int?
    var enemyCells: Int?
    var generationsTarget: Int?
    var missionDescription: String?
    var status: MissionStatus?
    var type: MissionType?
    
    init (maxMoves: Int = 0, playerCells: Int = 0, enemyCells: Int = 0, generationsTarget: Int = 0, type: MissionType? = nil,
          missionDescription: String = "", status: MissionStatus = .Running) {
        self.maxMoves = maxMoves
        self.playerCells = playerCells
        self.enemyCells = enemyCells
        self.generationsTarget = generationsTarget
        self.missionDescription = missionDescription
        self.type = type
        self.status = status
    }
}

class Mission {
    var params: MissionsModel?
    var successRule: ((Int)->())
    var failRule: ((Int)->())
    
    init(params: MissionsModel? = nil, successRule: @escaping ((Int)->()) = {(param) in}, failRule: @escaping ((Int)->()) = {(param) in}) {
        self.params = params
        self.successRule = successRule
        self.failRule = failRule
    }
    
}
