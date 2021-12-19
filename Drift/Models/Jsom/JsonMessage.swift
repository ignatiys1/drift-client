//
//  JsonMessage.swift
//  Drift
//
//  Created by Ignat Urbanovich on 3.11.21.
//

import Foundation
import UIKit

class JsonMessage: Decodable {
    var COMMAND: Int = 0
    var user: User = THIS_USER
    var object: String = ""
    var image: String = ""
//    {
//        get {
//            return self.object
//        }
//        set{
//            var str = newValue
//
//            str = str.replacingOccurrences(of: "u005B",with: "[");
//            str = str.replacingOccurrences(of:"u005D",with: "]");
//
//            str = str.replacingOccurrences(of:"u007B",with: "{");
//            str = str.replacingOccurrences(of:"u007D",with: "}");
//
//            str = str.replacingOccurrences(of:"u0022",with: "\"");
//            str = str.replacingOccurrences(of:"u003A",with: ":");
//
//            self.object = str
//        }
//    }
    
    
    func setObjWithRepl(from str: String){
        var str = str
        str = str.replacingOccurrences(of: "u005B",with: "[");
        str = str.replacingOccurrences(of:"u005D",with: "]");
        
        str = str.replacingOccurrences(of:"u007B",with: "{");
        str = str.replacingOccurrences(of:"u007D",with: "}");
        
        str = str.replacingOccurrences(of:"u0022",with: "\"");
        str = str.replacingOccurrences(of:"u003A",with: ":");
        
        str = str.replacingOccurrences(of:"u002C",with: ",");
        
        object = str
    }
    
    func setImageStr(by image: UIImage){
        guard let dataPng = image.jpegData(compressionQuality: 0.000005) else {return}
        print("\(dataPng)")
        self.image = String(decoding: dataPng, as: UTF8.self)
        
        
    }
    
    
    func getAskMessage()-> String {
        
        object = object.replacingOccurrences(of: "[",with: "u005B");
        object = object.replacingOccurrences(of:"]",with: "u005D");
        
        object = object.replacingOccurrences(of:"{",with: "u007B");
        object = object.replacingOccurrences(of:"}",with: "u007D");
        
        object = object.replacingOccurrences(of:"\"",with: "u0022");
        object = object.replacingOccurrences(of:":",with: "u003A");
        
        object = object.replacingOccurrences(of:",",with: "u002C");
        
        var jsonUser = ""
        do {
            jsonUser = (String(data: try JSONEncoder().encode(user), encoding: .utf8) ?? "")
        } catch {
            print(error)
        }
        
        
        return "{\"COMMAND\":" + String(COMMAND) + ",\"object\":\"" + object + "\",\"user\":" + jsonUser + "}"
    }
}
