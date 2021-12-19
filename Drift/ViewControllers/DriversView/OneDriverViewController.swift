//
//  OneDriverViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 3.12.21.
//

import UIKit

class OneDriverViewController: UIViewController {

    var driver: Driver?
    var oldTextFiledStr: String?
    
    
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var FIOField: UITextField!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var autoField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    var imageChanged = false
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Adapter.shared.delegateDriver = self
        
        if let driver = driver {
            
            FBClient.shared.getImage(withPath: driver.getImgPath(), imgName: "mainImg", completion: { image in
                guard let image = image else {return}
                self.driverImage.image = image
            })
            
            FIOField.text = driver.FIO
            nicknameField.text = driver.nickname
            autoField.text = driver.car
            countryField.text = driver.country
            cityField.text = driver.city
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        driverImage.isUserInteractionEnabled = true
        driverImage.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let driver = driver {
            if imageChanged {
                if let image = driverImage.image {
                    FBClient.shared.setImage(withPath: driver.getImgPath(), imgName: "mainImg", img: image, by: 1)
                    FBClient.shared.setImage(withPath: driver.getImgPath(), imgName: "icon", img: image, by: 10)
                }
                imageChanged = false
            }
            Adapter.shared.saveDriver(driverForSaving: driver)
        } else {
            driver = Driver()
            driver?.country = countryField.text ?? ""
            driver?.car = autoField.text ?? ""
            driver?.FIO = FIOField.text ?? ""
            driver?.city = cityField.text ?? ""
            driver?.nickname = nicknameField.text ?? ""
            
            Adapter.shared.saveDriver(driverForSaving: driver!)
        
            
        }
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}


extension OneDriverViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AdapterDelegateDriver, UITextFieldDelegate {
   
    func driverSaving(driverSaved: Driver?) {
        if let driverSaved = driverSaved {
            driver = driverSaved
            saveButtonOutlet.isEnabled = false
            if imageChanged {
                if let image = driverImage.image {
                    FBClient.shared.setImage(withPath: driverSaved.getImgPath(), imgName: "mainImg", img: image, by: 1)
                    FBClient.shared.setImage(withPath: driverSaved.getImgPath(), imgName: "icon", img: image, by: 10)
                }
                imageChanged = false
            }
        } else {
            let alert  = UIAlertController(title: "Ошибка сохранения", message: "Повторите позже", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        driverImage.image = info[.originalImage] as? UIImage
        if driverImage.image != nil {
            imageChanged = true
            saveButtonOutlet.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        oldTextFiledStr = textField.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if oldTextFiledStr != textField.text {
            switch textField {
            case FIOField:
                driver?.FIO = textField.text ?? ""
            case nicknameField:
                driver?.nickname = textField.text ?? ""
            case autoField:
                driver?.car = textField.text ?? ""
            case cityField:
                driver?.city = textField.text ?? ""
            case countryField:
                driver?.country = textField.text ?? ""
                
            default:
                print("default")
            }
            saveButtonOutlet.isEnabled = true
        }
        oldTextFiledStr = nil
    }
    
}
