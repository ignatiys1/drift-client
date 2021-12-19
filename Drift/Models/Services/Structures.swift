//
//  Structures.swift
//  Drift
//
//  Created by Ignat Urbanovich on 3.11.21.
//

import Foundation
import UIKit

enum UserTypes: String {
    case ordinary = "ORDINARY"
    case judge = "JUDGE"
    case org = "ORGANIZER"
    case driver = "DRIVER"
}


struct Cup: Decodable, Encodable{
    var idcup: Int
    var cupName: String
    var year: Int
    var organizerId: Int
    
    init(){
        idcup = 0
        cupName = "Error"
        year = 2020
        organizerId = 21
    }
    
    func getImgPath() -> String {
        var idToSave = (self.idcup as NSNumber).stringValue
        while idToSave.count < 6 {
            idToSave = "0\(idToSave)"
        }
        
        return "Cup/#\(idToSave)"
    }
}

struct User: Decodable, Encodable {
    var iduser: Int = 0
    var login = ""
    var password = ""
    var firstName = "Незарегистрированный"
    var lastName = "пользователь"
    var driverId = 0
    var type: String = UserTypes.ordinary.rawValue
    
    init(){
    }
    
    func getImgPath() -> String {
        var idToSave = (self.iduser as NSNumber).stringValue
        while idToSave.count < 12 {
            idToSave = "0\(idToSave)"
        }
        
        return "User/#\(idToSave)"
    }
    
    init(login: String, password: String) {
        self.login = login
        self.password = password
    }
    
    init(login: String, password: String, firstName: String, lastName: String, type: UserTypes) {
        
        self.login = login
        self.password = password
        self.lastName = lastName
        self.firstName = firstName
        self.type = type.rawValue
        
    }
}

struct Stage: Decodable, Encodable {
    var idstage: Int = 0
    var stageName = ""
    var cupId = 0
    var city = ""
    var status = 0
    var place = ""
    var firstJudgeId = 0
    var secondJudgeId = 0
    var thirdJudgeId = 0
    var firstGrid = 0
    
    var date: Date = Date(timeIntervalSinceNow: TimeInterval.nan)
    var daysDuration = 0
    
    var cup: Cup?
    
    init(_ name: String){
        self.stageName = name
    }
    
    init(){}
    
    func getImgPath() -> String {
        var idToSave = (self.idstage as NSNumber).stringValue
        while idToSave.count < 10 {
            idToSave = "0\(idToSave)"
        }
        
        return "Stage/#\(idToSave)"
    }
}

struct Run: Decodable, Encodable {
    var idstagetable: Int
    var stageId: Int
    var firstDriverId: Int
    var secondDriverId: Int
    var qual: Bool
    var score: Int
    var winnerId: Int
    var firstJudgeSolution: Int
    var secondJudgeSolution: Int
    var thirdJudgeSolution: Int
    var attempt: Int
    var status: Int

    var firstJudge: User
    var secondJudge: User
    var thirdJudge: User
    
    var firstDriver: Driver
    var secondDriver: Driver?
}

struct Driver: Decodable, Encodable {
    var iddriver: Int = 0
    var FIO: String = ""
    var nickname: String = ""
    var car: String = ""
    var country: String = ""
    var city: String = ""
    
    var user: User?
    
    
    
    func getImgPath() -> String {
        var idToSave = (self.iddriver as NSNumber).stringValue
        while idToSave.count < 12 {
            idToSave = "0\(idToSave)"
        }
        
        return "Driver/#\(idToSave)"
    }
}

struct JudgeDecision:Decodable, Encodable {
    var iduser: Int
    var idstagetable: Int
    var solution: Int
    var judgeNum: Int
    
    init(judgeId: Int, runId: Int, solution: Int, judgeNum: Int){
        self.solution = solution
        self.judgeNum = judgeNum
        iduser = judgeId
        idstagetable = runId
    }
}

struct stageParticipiant:Decodable, Encodable {
    var idStageParticipiants = 0
    var driverId: Int
    var stageId: Int
    var serialNumber: Int = 0
    var confirmed: Bool = false
    
    init(driverId: Int, stageId: Int) {
        self.driverId = driverId
        self.stageId = stageId
    }
}

struct Grid: Decodable, Encodable {
    var stageId: Int = 0
    var grids:[Dictionary<Int, Driver>] = []
    
    init(){}
    
    
    
}
