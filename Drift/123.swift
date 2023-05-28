//
//  FBClient.swift
//  Drift
//
//  Created by Ignat Urbanovich on 11.11.21.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit


class FBClient {
    
    static var shared: FBClient = {
        let instance = FBClient()

        return instance
    }()
    
    private init(){}
    
    func getImage(withPath path: String, imgName: String, completion: @escaping (UIImage?)->Void) {
        let storage = Storage.storage()
        let reference  = storage.reference()
        let pathRef = reference.child(path)
        
        var image: UIImage = UIImage(imageLiteralResourceName: "default_img.png")
        //var image: UIImage?
        print("trying to get an image...")
        let fileRef = pathRef.child(imgName + ".jpeg")
        fileRef.getData(maxSize: 5000*5000, completion: { data, error in
            guard error == nil else {return}
            
            image = UIImage(data: data!)!
            completion(image)
        })
        completion(image)
    }
    
    func setImage(withPath path: String, imgName: String, img: UIImage, by additQual: Double) {
        let storage = Storage.storage()
        let reference  = storage.reference()
        let pathRef = reference.child(path)
        
        
        var compr: Float = 1
        if img.size.width >= img.size.height {
            compr = Float(1/(img.size.width/1000))
        } else {
            compr = Float(1/(img.size.height/1000))
        }
        
        let fileRef = pathRef.child(imgName + ".jpeg")
        fileRef.putData(img.jpegData(compressionQuality: Double(compr)/additQual)!)
    }
}

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

//
//  Connection.swift
//  Drift
//
//  Created by Ignat Urbanovich on 2.11.21.
//

import Foundation
import UIKit

protocol ConnectionDelegate: AnyObject {
    func received(message: String)
}

class Connection: NSObject {
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
   
    weak var delegate: ConnectionDelegate? = Adapter.shared
    
    var maxReadLength = 102400
    
    private let ip = "188.127.251.235"
    //private let ip = "10.8.0.2"
    private let port: UInt32 = 8090

   
    var notEndedMessage: String?
    
    static var shared: Connection = {
        let instance = Connection()

        return instance
    }()
    
    
    func reconnect() {
        send(string_message: "{\"COMMAND\":999,\"object\":\"\",\"image\":\"\"}")
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           ip as CFString,
                                           port,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    private override init() {
        super.init()
        
         
        
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           ip as CFString,
                                           port,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
        
        
    }
    
    func send(string_message msg: String) {
        //print(msg)
        let data = "\(msg)".data(using: .utf8)!
        
        let dataSize = "\(data.count)".data(using: .utf8)!
        
        var dataSizeSIZE: UInt8 = UInt8(dataSize.count)
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error")
                return
            }
            
            dataSize.withUnsafeBytes {
                guard let pointerSize = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    print("Error")
                    return
                }
                
                
                outputStream.write(&dataSizeSIZE, maxLength: MemoryLayout.size(ofValue: dataSizeSIZE))
                outputStream.write(pointerSize, maxLength: dataSize.count)
                outputStream.write(pointer, maxLength: data.count)
            }
        }
    }
    
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
    
}

extension Connection: StreamDelegate {

    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("new message received")
            stopChatSession()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        var message = ""
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }

            // Construct the message object
            if let msgFromBuffer = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                if !msgFromBuffer.isEmpty {
                    message = message + msgFromBuffer
                }
            }
        }
        print("Принятое: \(message.count)")
        if message.last == "\r\n" && message != ""{
            if let msg = self.notEndedMessage {
                print("Итого: \(msg.count+message.count)")
                delegate?.received(message: "\(msg)\(message)")
                self.notEndedMessage = nil
            } else {
                delegate?.received(message: message)
            }
        } else {
            if let msg = self.notEndedMessage {
                self.notEndedMessage = msg + message
            } else {
                self.notEndedMessage =  message
            }
        }
    }

    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,length: Int) -> String? {
        
        var msg: String?
        
        do {
            msg = try String(
                bytesNoCopy: buffer,
                length: length,
                encoding: .utf8,
                freeWhenDone: true)
        } catch {
            Adapter.shared.repeatLastAsk()
            return nil
        }
       return msg
        
//        guard
//            let msg = String(
//                bytesNoCopy: buffer,
//                length: length,
//                encoding: .utf8,
//                freeWhenDone: true)
//        else {
//            return nil
//        }
//
//        return msg
    }

}

//
//  Adapter.swift
//  Drift
//
//  Created by Ignat Urbanovich on 3.11.21.
//

import Foundation
import UIKit
import SwiftUI


let decoder = JSONDecoder()
let encoder = JSONEncoder()


protocol AdapterDelegateCup: AnyObject {
    func doAnythingWith(cups: [Cup])
}

protocol AdapterDelegateOneCup: AnyObject {
    func doAnythingWith(stages: [Stage])
}

protocol AdapterDelegateLoginUser: AnyObject {
    func incorrectUser()
    func userExist(user: User)
}

protocol AdapterDelegateUser: AnyObject {
    
}

protocol AdapterDelegateSignUser: AnyObject {
    func signError()
    func userSigned()
}


protocol AdapterDelegateOnline: AnyObject {
    func setStage(stage: Stage)
    func setRun(run: Run?)
    func setDecision(_ decision: JudgeDecision)
}

protocol AdapterDelegateStage: AnyObject {
    func setJudgesArray(judges: [User])
    func stageSaving(withStage stage: Stage?)
    func setParticipiants(_ part: [stageParticipiant]?, isAfterSavind: Bool)
    func setStageRuns(runs: [Run]?)
    func setStatus(for stage: Stage)
    func setGrid(grid: Grid?)
}

protocol AdapterDelegateDriversList: AnyObject {
    func setDrivers(drivers: [Driver]?)
}

protocol AdapterDelegateDriver: AnyObject {
    func driverSaving(driverSaved: Driver?)
}


protocol AdapterDelegateRuns: AnyObject {
    func setStatus(runs: [Run]?)
}

class Adapter: ConnectionDelegate {
    
    
    weak var delegateCup: AdapterDelegateCup?
    weak var delegateOneCup: AdapterDelegateOneCup?
    weak var delegateLoginUser: AdapterDelegateLoginUser?
    weak var delegateSignUser: AdapterDelegateSignUser?
    weak var delegateUser: AdapterDelegateUser?
    weak var delegateOnline: AdapterDelegateOnline?
    weak var delegateStage: AdapterDelegateStage?
    weak var delegateDriversList: AdapterDelegateDriversList?
    weak var delegateDriver: AdapterDelegateDriver?
    weak var delegateRuns: AdapterDelegateRuns?
   
    let dateFormatter = DateFormatter()
    var lastMSG: JsonMessage?
    
    
    static var shared: Adapter = {
        let instance = Adapter()
        
        return instance
    }()
    
    private init(){
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        
        
    }
    
    func received(message: String) {
        var serverAnswer = JsonMessage();
        //print(message)
        serverAnswer = GetJsonMessage(fromString: message)
        
        switch (serverAnswer.COMMAND) {
        case SERVER_CONST_NULL:
            print("srv-error")
            repeatLastAsk()
        case SERVER_CONST_WITH_CUPS:
            let cups = GetCups(fromString: serverAnswer.object)
            guard cups.isEmpty else {
                delegateCup?.doAnythingWith(cups: cups)
                return
            }
        case SERVER_CONST_CUPS_EMPTY:
            let cups: [Cup] = []
            delegateCup?.doAnythingWith(cups: cups)
        case SERVER_CONST_WITH_STAGES:
            let stages = GetStages(fromString: serverAnswer.object)
            guard stages.isEmpty else {
                delegateOneCup?.doAnythingWith(stages: stages)
                return
            }
        case SERVER_CONST_STAGES_EMPTY:
            let stages: [Stage] = []
            delegateOneCup?.doAnythingWith(stages: stages)
        case SERVER_CONST_ERROR_CUP_SAVING:
            print("данные не сохранены")
        case SERVER_CONST_CUP_SAVING_SUCCESS:
            print("Данные сохранены")
        case SERVER_CONST_INCORRECT_USER:
            delegateLoginUser?.incorrectUser()
        case SERVER_CONST_USER_EXIST:
            let user = GetUser(fromString: serverAnswer.object)
            THIS_USER = user
            delegateLoginUser?.userExist(user: user)
        case SERVER_CONST_USER_EXIST_CANT_SIGN:
            delegateSignUser?.signError()
        case SERVER_CONST_USER_SIGNED:
            THIS_USER = GetUser(fromString: serverAnswer.object)
            delegateSignUser?.userSigned()
        case SERVER_CONST_ONLINE_STAGE:
            delegateOnline?.setStage(stage: GetStage(fromString: serverAnswer.object))
        case SERVER_CONST_ONLINE_RUN:
            delegateOnline?.setRun(run: GetRun(fromString: serverAnswer.object))
        case SERVER_CONST_ONLINE_JUDGE_DECISION:
            delegateOnline?.setDecision(GetDecision(fromString: serverAnswer.object))
        case SERVER_CONST_WITH_JUDGES:
            delegateStage?.setJudgesArray(judges: GetUsers(fromString: serverAnswer.object))
        case SERVER_CONST_STAGE_SAVED:
            delegateStage?.stageSaving(withStage: GetStage(fromString: serverAnswer.object))
        case SERVER_CONST_STAGE_NOT_SAVED:
            delegateStage?.stageSaving(withStage: nil)
        case SERVER_CONST_USER_OF_SESSION:
            THIS_USER = serverAnswer.user
        case SERVER_CONST_WITH_DRIVERS:
            let drivers = GetDrivers(fromString: serverAnswer.object)
            if let drivers = drivers {
                delegateDriversList?.setDrivers(drivers: drivers)
            } else {
                getDrivers()
            }
        case SERVER_CONST_DRIVER_SAVED:
            delegateDriver?.driverSaving(driverSaved: GetDriver(fromString: serverAnswer.object))
        case SERVER_CONST_DRIVER_SAVING_ERROR:
            delegateDriver?.driverSaving(driverSaved: nil)
        case SERVER_CONST_WITH_STAGE_PARICIPIANTS:
            delegateStage?.setParticipiants(GetParticipiants(fromString: serverAnswer.object), isAfterSavind: false)
        case SERVER_CONST_NO_STAGE_PARICIPIANTS:
            let emptyStPart: [stageParticipiant] = []
            delegateStage?.setParticipiants(emptyStPart, isAfterSavind: false)
        case SERVER_CONST_PARICIPIANTS_SAVED:
            delegateStage?.setParticipiants(GetParticipiants(fromString: serverAnswer.object), isAfterSavind: true)
        case SERVER_CONST_PARICIPIANTS_NOT_SAVED:
            delegateStage?.setParticipiants(nil, isAfterSavind: true)
        case SERVER_CONST_WITH_STAGE_RUNS:
            delegateStage?.setStageRuns(runs: GetRuns(fromString: serverAnswer.object))
        case SERVER_CONST_NO_STAGE_RUNS:
            let emptyStRun: [Run] = []
            delegateStage?.setStageRuns(runs: emptyStRun)
        case SERVER_CONST_STAGE_NEW_STATUS:
            delegateStage?.setStatus(for: GetStage(fromString: serverAnswer.object))
        case SERVER_CONST_RUN_NEW_STATUS:
            delegateRuns?.setStatus(runs: GetRuns(fromString: serverAnswer.object))
        case SERVER_CONST_RUN_STATUS_NOT_UPDATED:
            delegateRuns?.setStatus(runs: nil)
        case SERVER_CONST_WITH_STAGE_GRID:
            delegateStage?.setGrid(grid: GetGrid(fromString: serverAnswer.object))
        case SERVER_CONST_ERROR_GETTIN_GRID:
            let emptyGrid: Grid = Grid()
            delegateStage?.setGrid(grid: emptyGrid)
        
            
            
        default:
            break
        }
        
    }
    
    func repeatLastAsk(){
        if let lastMSG = lastMSG {
            Connection.shared.send(string_message: lastMSG.getAskMessage())
            //как правило, со второй попытки загружается
            //если нет, закомментить следующую строку
            self.lastMSG = nil
        }
    }
    
    func askForCups(_ forUser: Bool){
        let jsonAsk = JsonMessage()
        
        if forUser {
            jsonAsk.COMMAND = CLIENT_CONST_GET_CUPS_FOR_USER
        } else {
            jsonAsk.COMMAND = CLIENT_CONST_GET_CUPS
        }
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func askForOneCupInfo(for cup: Cup){
        var data: Data = Data()
        do {
            data = try encoder.encode(cup)
        } catch {
            print(error)
        }
        
        let strCup = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_GET_ONE_CUP_INFO
        jsonAsk.setObjWithRepl(from: strCup)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
        
        
    }
    
    
    func saveCup(cupForSaving: Cup){
        var data: Data = Data()
        do {
            data = try encoder.encode(cupForSaving)
        } catch {
            print(error)
        }
        
        let strCup = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SAVE_CUP
        jsonAsk.setObjWithRepl(from: strCup)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func saveStage(stageForSaving: Stage){
        var data: Data = Data()
        do {
            data = try encoder.encode(stageForSaving)
        } catch {
            print(error)
        }
        
        let strStage = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SAVE_STAGE
        jsonAsk.setObjWithRepl(from: strStage)
        jsonAsk.user = THIS_USER
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    
    func checkUser(user: User){
        var data: Data = Data()
        do {
            data = try encoder.encode(user)
        } catch {
            print(error)
        }
        
        let userJson = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_CHECK_USER
        jsonAsk.setObjWithRepl(from: userJson)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func getUser(_ id: Int){
        
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_GET_FULL_USER
        jsonAsk.setObjWithRepl(from: "\(id)")
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func addUser(_ user: User){
        var data: Data = Data()
        do {
            data = try encoder.encode(user)
        } catch {
            print(error)
        }
        
        let userJson = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SIGN_USER
        jsonAsk.setObjWithRepl(from: userJson)
        
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    
    func endSession(){
        let jsonAsk = JsonMessage()
        jsonAsk.COMMAND = CLIENT_CONST_END_SESSION
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    
    func getOnline() {
        let jsonAsk = JsonMessage()
        jsonAsk.COMMAND = CLIENT_CONST_GET_ONLINE
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func sendDecision(_ decision: JudgeDecision){
        var data: Data = Data()
        do {
            data = try encoder.encode(decision)
        } catch {
            print(error)
        }
        
        let decJson = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_ADD_JUDGE_DECISION
        jsonAsk.setObjWithRepl(from: decJson)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    
    func getAllJudges() {
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_GET_ALL_JUDGES
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func getDrivers() {
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_GET_ALL_DRIVERS
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func getStageParticipiants(for stage: Stage) {
        let jsonAsk = JsonMessage()
        
        var data: Data = Data()
        do {
            data = try encoder.encode(stage)
        } catch {
            print(error)
        }
        
        let str = String(decoding: data, as: UTF8.self)
        
        
        jsonAsk.COMMAND = CLIENT_CONST_GET_STAGE_PARTICIPIANTS
        jsonAsk.setObjWithRepl(from: str)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func getStageRuns(for stage: Stage) {
        let jsonAsk = JsonMessage()
        
        var data: Data = Data()
        do {
            data = try encoder.encode(stage)
        } catch {
            print(error)
        }
        
        let str = String(decoding: data, as: UTF8.self)
        
        jsonAsk.COMMAND = CLIENT_CONST_GET_STAGE_RUNS
        jsonAsk.setObjWithRepl(from: str)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    
    func saveDriver(driverForSaving: Driver){
        var data: Data = Data()
        do {
            data = try encoder.encode(driverForSaving)
        } catch {
            print(error)
        }
        
        let str = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SAVE_DRIVER
        jsonAsk.setObjWithRepl(from: str)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func saveParticipiants(parts: [stageParticipiant]){
        var data: Data = Data()
        do {
            data = try encoder.encode(parts)
        } catch {
            print(error)
        }
        
        let str = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SAVE_PARTICIPIANTS
        jsonAsk.setObjWithRepl(from: str)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func setStageStatus(stage: Stage){
        var data: Data = Data()
        do {
            data = try encoder.encode(stage)
        } catch {
            print(error)
        }
        
        let str = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SET_STAGE_STATUS
        jsonAsk.setObjWithRepl(from: str)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }
    
    func setRunStatus(for run: Run){
        var data: Data = Data()
        do {
            data = try encoder.encode(run)
        } catch {
            print(error)
        }
        
        let str = String(decoding: data, as: UTF8.self)
        let jsonAsk = JsonMessage()
        
        jsonAsk.COMMAND = CLIENT_CONST_SET_RUN_STATUS
        jsonAsk.setObjWithRepl(from: str)
        
        lastMSG = jsonAsk
        Connection.shared.send(string_message: jsonAsk.getAskMessage())
    }

    
}


func GetJsonMessage(fromString msg: String) -> JsonMessage{
    var jsonMsg = JsonMessage()
    if let data = msg.data(using: .utf8) {
        do {
            jsonMsg = try decoder.decode(JsonMessage.self, from: data)
        } catch {
            print(error)
        }
    }
    jsonMsg.setObjWithRepl(from: jsonMsg.object)
    return jsonMsg
}


func GetCups(fromString msg: String) ->  [Cup] {
    var cups: [Cup] = []
    if let data = msg.data(using: .utf8) {
        do {
            cups = try decoder.decode([Cup].self, from: data)
        } catch {
            print(error)
        }
    }
    return cups
}

func GetStages(fromString msg: String) ->  [Stage] {
    var stages: [Stage] = []
    if let data = msg.data(using: .utf8) {
        do {
            
            stages = try decoder.decode([Stage].self, from: data)
        } catch {
            print(error)
        }
    }
    return stages
}

func GetStage(fromString msg: String) ->  Stage {
    var stage: Stage?
    if let data = msg.data(using: .utf8) {
        do {
            stage = try decoder.decode(Stage.self, from: data)
        } catch {
            print(error)
        }
    }
    return stage!
}


func GetRun(fromString msg: String) ->  Run? {
    var run: Run?
    if let data = msg.data(using: .utf8) {
        do {
            run = try decoder.decode(Run.self, from: data)
        } catch {
            print(error)
        }
    }
    //print(msg)
    return run
}

func GetRuns(fromString msg: String) ->  [Run] {
    var runs: [Run] = []
    if let data = msg.data(using: .utf8) {
        do {
            runs = try decoder.decode([Run].self, from: data)
        } catch {
            print(error)
        }
    }
    //print(msg)
    return runs
}

func GetUser(fromString msg: String) ->  User {
    var user: User = User()
    if let data = msg.data(using: .utf8) {
        do {
            user = try decoder.decode(User.self, from: data)
        } catch {
            print(error)
        }
    }
    return user
}

func GetGrid(fromString msg: String) ->  Grid? {
    var grid: Grid? = nil
    if let data = msg.data(using: .utf8) {
        do {
            grid = try decoder.decode(Grid.self, from: data)
        } catch {
            print(error)
        }
    }
    return grid
}


func GetUsers(fromString msg: String) ->  [User] {
    var user: [User]?
    if let data = msg.data(using: .utf8) {
        do {
            user = try decoder.decode([User].self, from: data)
        } catch {
            print(error)
        }
    }
    return user!
}


func GetDrivers(fromString msg: String) ->  [Driver]? {
    var drivers: [Driver]?
    if let data = msg.data(using: .utf8) {
        do {
            drivers = try decoder.decode([Driver].self, from: data)
        } catch {
            print(error)
        }
    }
    return drivers
}


func GetDriver(fromString msg: String) ->  Driver? {
    var driver: Driver?
    if let data = msg.data(using: .utf8) {
        do {
            driver = try decoder.decode(Driver.self, from: data)
        } catch {
            print(error)
        }
    }
    return driver
}

func GetDecision(fromString msg: String) ->  JudgeDecision {
    var dec: JudgeDecision?
    if let data = msg.data(using: .utf8) {
        do {
            dec = try decoder.decode(JudgeDecision.self, from: data)
        } catch {
            print(error)
        }
    }
    return dec!
}

func GetParticipiants(fromString msg: String) ->  [stageParticipiant]? {
    var part: [stageParticipiant]?
    if let data = msg.data(using: .utf8) {
        do {
            part = try decoder.decode([stageParticipiant].self, from: data)
        } catch {
            print(error)
        }
    }
    return part
}
