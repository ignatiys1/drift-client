//
//  StageViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 28.11.21.
//

import UIKit

class StageViewController: UIViewController {

    var stage: Stage = Stage()
    var organizerMode: Bool?
    var changeble: Bool?
    var judges: [User]?
    var judgeChangingNum = 0
    var allDrivers: [Driver] = []
    var stageChanged = false
    var participiants: [stageParticipiant] = []
    var runs: [Run] = []
    var grid: Grid?
    
    @IBOutlet weak var stageNameField: UITextField!
    @IBOutlet weak var cupNameFiled: UITextField!
    
    @IBOutlet weak var stageDatePicker: UIDatePicker!
    @IBOutlet weak var stageDate: UITextField!
    
    @IBOutlet weak var judgeName1: UITextField!
    @IBOutlet weak var judgeName2: UITextField!
    @IBOutlet weak var judgeName3: UITextField!
    
    @IBOutlet weak var judgePickerView: UIPickerView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var driversButtonOutlet: UIButton!
    @IBOutlet weak var startOutlet: UIButton!
    
    @IBOutlet weak var place: UITextField!
    @IBOutlet weak var city: UITextField!
    
    @IBOutlet weak var ConfirmedDriversLabel: UILabel!
    @IBOutlet weak var AllDriversLabel: UILabel!
    
    @IBOutlet weak var driversNum: UILabel!
    @IBOutlet weak var confirmedDriversNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if organizerMode == nil {
            organizerMode = false
        }
        Adapter.shared.delegateStage = self
        Adapter.shared.delegateDriversList = self
        Adapter.shared.getAllJudges()
        Adapter.shared.getDrivers()
        
        
        judgePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        
        
        stageDate.inputViewController?.setEditing(false, animated: true)
        
        stageDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
        stageDatePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: UIControl.Event.valueChanged)
        
        
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let cup = stage.cup else {
            return
        }
        Adapter.shared.askForOneCupInfo(for: cup)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cupNameFiled.text = stage.cup?.cupName
        cupNameFiled.isEnabled = false
        
        switch stage.status {
        case 0:
            Adapter.shared.getStageParticipiants(for: stage)
            startOutlet.setTitle("СТАРТ", for: .normal)
        case 1:
            Adapter.shared.getStageRuns(for: stage)
            startOutlet.setTitle("TOP 32", for: .normal)
            ConfirmedDriversLabel.text = "Осталось заездов"
            AllDriversLabel.text = "Заездов в квале"
            //organizerMode = false
        case 2:
            Adapter.shared.getStageRuns(for: stage)
            startOutlet.setTitle("TOP 16", for: .normal)
            //ConfirmedDriversLabel.text = "Осталось заездов"
            //AllDriversLabel.text = "Заездов в квале"
            //organizerMode = false
        case 3:
            Adapter.shared.getStageRuns(for: stage)
            startOutlet.setTitle("TOP 8", for: .normal)
            //ConfirmedDriversLabel.text = "Осталось заездов"
            //AllDriversLabel.text = "Заездов в квале"
            //organizerMode = false
        case 4:
            Adapter.shared.getStageRuns(for: stage)
            startOutlet.setTitle("TOP 4", for: .normal)
            //ConfirmedDriversLabel.text = "Осталось заездов"
            //AllDriversLabel.text = "Заездов в квале"
            //organizerMode = false
        case 7:
            Adapter.shared.getStageRuns(for: stage)
            startOutlet.setTitle("ЗАВЕРШИТЬ", for: .normal)
            //organizerMode = false
        default:
            startOutlet.isHidden = true
            //organizerMode = false
        }
        
        
        if stage.idstage != 0 {
            
            
            
            
         
            stageNameField.text = stage.stageName
            stageDate.text = stage.date.formatted()
            stageDatePicker.date = stage.date
            
            city.text = stage.city
            place.text = stage.place
            
            driversButtonOutlet.isEnabled = true
            
        } else {
            stageDatePicker.date = .now
        }
        
        
        
        if organizerMode! {
            
        } else {
            AllDriversLabel.isHidden = true
            
            driversNum.isHidden = true
            stageDate.isHidden = true
            
            
            stageDatePicker.isHidden = true
            saveButtonOutlet.isHidden = true
            
            startOutlet.isEnabled = false
            startOutlet.isHidden = true
            
            stageNameField.isEnabled = false
            city.isEnabled = false
            place.isEnabled = false
            stageDatePicker.isEnabled = false
        
            judgeName1.isEnabled = false
            judgeName2.isEnabled = false
            judgeName3.isEnabled = false
        }
        
    }
    
    @objc func dateChanged(sender: AnyObject) {
        stage.date = self.stageDatePicker.date
        saveButtonOutlet.isEnabled = true
        stageChanged = true
    }
    

    @IBAction func startAction(_ sender: Any) {
        
        if stage.idstage != 0 {
            
            stage.status += 1
            
            Adapter.shared.setStageStatus(stage: stage)
        }
        
    }
 
    @IBAction func saveAction(_ sender: Any) {
        if stageChanged {
            Adapter.shared.saveStage(stageForSaving: stage)
        }
        Adapter.shared.saveParticipiants(parts: participiants)
    }
    
    @IBAction func driversAction(_ sender: Any) {
        
        switch stage.status {
        case 0:
            guard allDrivers.count != 0 else {
                return
            }
            
            performSegue(withIdentifier: "goToStageDrivers", sender: self)
        case 1:
            guard runs.count != 0 else {
                return
            }
            performSegue(withIdentifier: "goToStageQual", sender: self)
        case 2...10:
            guard grid?.grids[0].count != 0 else {
                return
            }
            performSegue(withIdentifier: "goToStagePair", sender: self)
            
        default:
            break
        }
        
        
        
    }
   
    func SetJudgeNames() {
        if let judges = judges {
            for judge in judges {
                switch judge.iduser {
                case stage.firstJudgeId:
                    judgeName1.text = judge.firstName + " " + judge.lastName
                    fallthrough
                case stage.secondJudgeId:
                    judgeName2.text = judge.firstName + " " + judge.lastName
                    fallthrough
                case stage.thirdJudgeId:
                    judgeName3.text = judge.firstName + " " + judge.lastName
                    fallthrough
                default:
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToStageDrivers" {
            let sdvc = segue.destination as! StageDriversTableViewController
            
            if organizerMode ?? false {
                sdvc.organizerView = true
                sdvc.changeble = true
            }
            
            
            var partsTemp = self.participiants
            var removedNum = 0
            for (index,partTemp) in partsTemp.enumerated() {
                if !partTemp.confirmed {
                    partsTemp.remove(at: index-removedNum)
                    removedNum += 1
                }
            }
            
            sdvc.delegate = self
            sdvc.allDrivers = self.allDrivers
            sdvc.stageId = self.stage.idstage
            
            if organizerMode ?? false {
            sdvc.stagePart = self.participiants
            sdvc.stageDrivers = GetStageDrivers(self.participiants)
            } else {
                sdvc.stagePart = partsTemp
                sdvc.stageDrivers = GetStageDrivers(partsTemp)
                
            }
        } else if segue.identifier == "goToStageQual" {
        
            let sqvc = segue.destination as! StageQualTableViewController
            
            if organizerMode ?? false {
                sqvc.organizerView = true
                sqvc.changeble = true
            }
            
            sqvc.stage = self.stage
            sqvc.thisRuns = self.runs
        
        } else if segue.identifier == "goToStagePair" {
            if let grid = grid {
                let spvc = segue.destination as! StagePairViewController
                
                spvc.grid = grid
            }
        
        }
    }
    
    
    func GetStageDrivers(_ parts: [stageParticipiant]) -> [Driver] {
    
        var stPart: [Driver] = []
        
        for part in parts {
            for driver in allDrivers {
            if part.driverId == driver.iddriver {
                    stPart.append(driver)
                    break
                }
            }
        }
        return stPart
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension StageViewController: AdapterDelegateStage, AdapterDelegateDriversList, StageDriversListDelegate {
    func setGrid(grid: Grid?) {
        if let grid = grid {
            if grid.stageId == 0 {
                
            } else {
                self.grid = grid
            }
        } else {
            Adapter.shared.getStageRuns(for: stage)
        }
    }
    
   
    func setStatus(for stage: Stage) {
        self.stage = stage
        self.viewWillAppear(true)
        self.viewDidAppear(true)
    }
    
    func setStageRuns(runs: [Run]?) {
        if let runs = runs {
            self.runs = runs
            if stage.status == 1 {
            driversNum.text = "\(runs.count/3)"
            
            let count = runs.filter({$0.status == 0}).count
                confirmedDriversNum.text = "\((count-(count%3))/3)"
            } else if stage.status == 2 {
                
            }
            
        } else {
            Adapter.shared.getStageRuns(for: stage)
        }

        
        
    }
    
    // from StageDriversListDelegate
    func setParticipiants(parts: [stageParticipiant]) {
        self.participiants = parts
        self.saveButtonOutlet.isEnabled = true
        driversButtonOutlet.titleLabel?.text = "\(parts.count)"
        
    }
    
    //from AdapterDelegateStage
    func setParticipiants(_ part: [stageParticipiant]?, isAfterSavind: Bool) {
        if let part = part {
            participiants = part
            var confNum = 0
            for participiant in participiants {
                if participiant.confirmed {
                    confNum += 1
                }
            }
            
            confirmedDriversNum.text = "\(confNum)"
            driversNum.text = "\(participiants.count)"

            if isAfterSavind {
                let alert  = UIAlertController(title: nil, message: "Пилоты добавлены", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }
        } else {
            if isAfterSavind {
            
            } else {
                Adapter.shared.getStageParticipiants(for: stage)
            }
        }
    }
    
    func stageSaving(withStage stage: Stage?) {
        if let stage = stage {
            self.stage = stage
            stageChanged = false
            self.viewWillAppear(false)
        } else {
            let alert  = UIAlertController(title: "Ошибка сохранения", message: "Повторите позже", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setJudgesArray(judges: [User]) {
        self.judges = judges
        judgePickerView.reloadAllComponents()
        SetJudgeNames()
    }
    
    func setDrivers(drivers: [Driver]?) {
        if let drivers = drivers {
            self.allDrivers = drivers
        }
    }
}

extension StageViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return judges?.count  ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return judges?[row].lastName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
        switch judgeChangingNum {
        case 1:
            self.judgeName1.text = (judges?[row].firstName ?? "") + " " + (judges?[row].lastName ?? "")
            
            self.stage.firstJudgeId = judges?[row].iduser ?? 0
        case 2:
            self.judgeName2.text = (judges?[row].firstName ?? "") + " " + (judges?[row].lastName ?? "")
            
            self.stage.secondJudgeId = judges?[row].iduser ?? 0
        case 3:
            self.judgeName3.text = (judges?[row].firstName ?? "") + " " + (judges?[row].lastName ?? "")
            
            self.stage.thirdJudgeId = judges?[row].iduser ?? 0
        default:
            print("")
        }
        
        self.judgePickerView.isHidden = true
        self.city.isHidden = false
        self.place.isHidden = false
        
        self.saveButtonOutlet.isEnabled = true
        stageChanged = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.judgeName1:
            judgeChangingNum = 1
            self.judgePickerView.isHidden = false
            self.judgePickerView.selectRow(getRow(by: stage.firstJudgeId), inComponent: 0, animated: false)
            self.city.isHidden = true
            self.place.isHidden = true
            
            textField.endEditing(true)
            
        case self.judgeName2:
            judgeChangingNum = 2
            self.judgePickerView.isHidden = false
            self.judgePickerView.selectRow(getRow(by: stage.secondJudgeId), inComponent: 0, animated: false)
            
            self.city.isHidden = true
            self.place.isHidden = true
            textField.endEditing(true)
        case self.judgeName3:
            judgeChangingNum = 3
            self.judgePickerView.isHidden = false
            self.judgePickerView.selectRow(getRow(by: stage.thirdJudgeId), inComponent: 0, animated: false)
            
            self.city.isHidden = true
            self.place.isHidden = true
            textField.endEditing(true)
        default:
            judgeChangingNum = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.saveButtonOutlet.isEnabled = true
        stageChanged = true
    }
    
    func getRow(by judgeId: Int) -> Int {
        if let judges = judges {
            for (index, judge) in judges.enumerated() {
                if judge.iduser == judgeId {
                    return index
                }
            }
        }
        return 0
    }
    
}

