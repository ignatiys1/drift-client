//
//  LoginViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 12.11.21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Adapter.shared.delegateLoginUser = self
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        if !loginField.hasText || !passwordField.hasText {
         
            return
        }
        
        Adapter.shared.checkUser(user: User(login: loginField.text!, password: passwordField.text!))
        
        passwordField.text = nil
        loginField.text = nil
        
    }
    
    @IBAction func regAction(_ sender: Any) {
        
        
    }
 
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension LoginViewController: AdapterDelegateLoginUser {
    func incorrectUser() {
        self.loginField.text = ""
        self.passwordField.text = ""
        
        let alert  = UIAlertController(title: "Ошибка", message: "Неверные логин или пароль", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func userExist(user: User) {
        THIS_USER = user
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loginAction(self)
        self.view.endEditing(true)
        return false
    }
}
