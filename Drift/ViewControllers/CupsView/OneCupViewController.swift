//
//  OneCupViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 4.11.21.
//

import UIKit

class OneCupViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainCupImageView: UIImageView!
    @IBOutlet weak var cupNameLabel: UILabel!
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var addStageOutlet: UIButton!
    @IBOutlet weak var cupNameField: UITextField!
    
    var cup: Cup?
    var stages: [Stage] = []
    var stageForSend: Stage?
    var imageChanged = false
    var canEditCup: Bool = false
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func saveAction(_ sender: Any) {
        if let cup = cup {
            if imageChanged {
                if let image = mainCupImageView.image {
                    FBClient.shared.setImage(withPath: cup.getImgPath(), imgName: "mainImg", img: image, by: 1)
                    FBClient.shared.setImage(withPath: cup.getImgPath(), imgName: "icon", img: image, by: 10)
                    imageChanged = false
                }
            }
            Adapter.shared.saveCup(cupForSaving: cup)
        }
    }
    
    @IBAction func addStageAction(_ sender: Any) {
        if cup != nil {
            stageForSend = nil
            performSegue(withIdentifier: "goToOneStage", sender: self)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Adapter.shared.delegateOneCup = self
        tableView.dataSource = self
        tableView.delegate = self
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        mainCupImageView.clipsToBounds = true
        mainCupImageView.layer.cornerRadius = 75
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        mainCupImageView.isUserInteractionEnabled = true
        mainCupImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if let cup = cup {
            Adapter.shared.askForOneCupInfo(for: cup)
            
            if cup.organizerId == THIS_USER.iduser {
                canEditCup = true
            }
            
            cupNameLabel.text = cup.cupName
            cupNameField.text = cup.cupName
            
            FBClient.shared.getImage(withPath: cup.getImgPath(), imgName: "mainImg", completion: { image in
                guard let image = image else {return}
                self.mainCupImageView.image = image
            })
        } else {
            canEditCup = true
        }
        
        
        if canEditCup {
            cupNameLabel.isHidden = true
        } else {
            cupNameField.isHidden = true
            addStageOutlet.isHidden = true
            
            
            addStageOutlet.isEnabled = false
            saveOutlet.isEnabled = false
        }

    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        
        if canEditCup {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOneStage" {
            let svc = segue.destination as! StageViewController
            if let stageForSend = stageForSend {
                svc.stage = stageForSend
                
            } else {
                svc.stage = Stage()
                svc.stage.cup = cup
                svc.stage.cupId = cup!.idcup
            }
            
            svc.organizerMode = canEditCup
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension OneCupViewController: AdapterDelegateOneCup {
    func doAnythingWith(stages: [Stage]) {
        self.stages = stages
        self.tableView.reloadData()
        
    }
    
}





extension OneCupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stages.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StageCell", for: indexPath)
        
        let stage = stages[indexPath.row]
        
        cell.textLabel?.text = stage.stageName
        
        stages[indexPath.row].cup = cup
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        stageForSend = stages[indexPath.row]
        performSegue(withIdentifier: "goToOneStage", sender: self)
        
    }

}


extension OneCupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        mainCupImageView.image = info[.originalImage] as? UIImage
        imageChanged = true
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
