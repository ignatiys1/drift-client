//
//  UserViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 12.11.21.
//

import UIKit

class UserViewController: UIViewController {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    
    var imageChanged = false
    let imagePicker = UIImagePickerController()
    
    var drivers: [Driver]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Adapter.shared.delegateUser = self
        Adapter.shared.delegateDriversList = self
        tableView.dataSource = self
        tableView.delegate = self
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = 75
        
        
    
        
        
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if THIS_USER.iduser != 0 {
            UserDefaults.standard.set(THIS_USER.iduser, forKey: "user_uid_key")
            UserDefaults.standard.synchronize()
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            userImage.isUserInteractionEnabled = true
            userImage.addGestureRecognizer(tapGestureRecognizer)
        }
        userName.text = THIS_USER.firstName + " " + THIS_USER.lastName
        
        
        
        FBClient.shared.getImage(withPath: THIS_USER.getImgPath(), imgName: "mainImg", completion: { image in
            guard let image = image else {return}
            self.userImage.image = image
        })
        Adapter.shared.getDrivers()
        
    }
    
    @IBAction func exitAction(_ sender: Any) {
        THIS_USER = User()
        UserDefaults.standard.set(nil, forKey: "user_uid_key")
        UserDefaults.standard.synchronize()
        self.viewWillAppear(true)
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDrivers" {
            
            if let drivers = drivers {
                (segue.destination as! DriversTableViewController).drivers = drivers
            } else {
                
            }
        } else if segue.identifier == "goToLogin" {
            
        }
    }
    
    
}


extension UserViewController: AdapterDelegateUser, AdapterDelegateDriversList {
    func setDrivers(drivers: [Driver]?) {
        if let drivers = drivers {
            self.drivers = drivers
            tableView.reloadData()
        } else {
            Adapter.shared.getDrivers()
        }
    }
    
    
    
}





extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if THIS_USER.type == UserTypes.ordinary.rawValue {
            // для обычных пользователей
            return 1
        } else {
            //для судей, пилотов и организаторов
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if THIS_USER.iduser == 0 {
                return 1
            }
            //первая секция у всех одинаковая
            return 2
        } else if section == 1 {
            //для организатора
            if THIS_USER.type == UserTypes.org.rawValue {
                return 2
            }
        }
        return 0
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
            if THIS_USER.iduser != 0 {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Логин:"
                    cell.detailTextLabel?.text = THIS_USER.login
                case 1:
                    cell.textLabel?.text = "Пароль:"
                    var secPass = ""
                    for _ in 1...THIS_USER.password.count {
                        secPass = secPass + "*"
                    }
                    cell.detailTextLabel?.text = secPass
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Вход/Регистрация"
                    cell.detailTextLabel?.text = ""
                default:
                    break
                }
            }
        } else if indexPath.section == 1 {
            if THIS_USER.type == UserTypes.org.rawValue {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Мои чемпионаты"
                    cell.detailTextLabel?.text = ""
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Пилоты"
                    cell.detailTextLabel?.text = String(describing: drivers?.count ?? 0)
                }
                
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        switch THIS_USER.type {
        case UserTypes.ordinary.rawValue:
            if THIS_USER.iduser == 0 {
                performSegue(withIdentifier: "goToLogin", sender: self)
            } else {
                
            }
        case UserTypes.org.rawValue:
            switch indexPath.section {
            case 1:
                switch indexPath.row {
                case 0:
                    let cupsVC = storyboard?.instantiateViewController(withIdentifier: "navCupsView")
                    present(cupsVC!, animated: true, completion: nil)
                case 1:
                    tableView.deselectRow(at: indexPath, animated: true)
                    performSegue(withIdentifier: "goToDrivers", sender: self)
                default:
                    break
                }
            default:
                break
            }
        default:
            break
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}


extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        userImage.image = info[.originalImage] as? UIImage
        if let image = userImage.image {
            FBClient.shared.setImage(withPath: THIS_USER.getImgPath(), imgName: "mainImg", img: image, by: 1)
            FBClient.shared.setImage(withPath: THIS_USER.getImgPath(), imgName: "icon", img: image, by: 10)
            imageChanged = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
