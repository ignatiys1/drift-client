//
//  RegViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 15.11.21.
//

import UIKit

class RegViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var typesView: UIPickerView!
    
    var type: UserTypes = UserTypes.ordinary
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Adapter.shared.delegateSignUser = self
        typesView.delegate = self
        typesView.dataSource = self
        
    }
    

    
    @IBAction func regAction(_ sender: Any) {
        
        type = getType()
        if loginField.hasText && passwordField.hasText && nameField.hasText && lastNameField.hasText {
            Adapter.shared.addUser(User(login: loginField.text!, password: passwordField.text!, firstName: nameField.text!, lastName: lastNameField.text!, type: type))
        }
        
    }
    
    
    
    func getType() -> UserTypes {
        let row = typesView.selectedRow(inComponent: 0)
        
        if row == 0 {
            return UserTypes.ordinary
        }
        if row == 1 {
            return UserTypes.org
        }
        if row == 2 {
            return UserTypes.judge
        }
        return UserTypes.ordinary
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension RegViewController: UIPickerViewDelegate, UIPickerViewDataSource, AdapterDelegateSignUser {
    func signError() {
        print("Пользователь существует")
    }
    
    func userSigned() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            if row == 0 {
                return "Обычный"
            }
            if row == 1 {
                return "Организатор"
            }
            if row == 2 {
                return "Судья"
            }
        }
        
        return ""
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return 3
        }
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}
