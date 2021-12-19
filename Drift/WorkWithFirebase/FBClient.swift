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

