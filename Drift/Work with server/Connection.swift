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
