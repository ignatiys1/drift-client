//
//  StageDriversTableViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 4.12.21.
//

import UIKit

protocol StageDriversListDelegate: AnyObject {
    func setParticipiants(parts: [stageParticipiant])
}

class StageDriversTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var allDrivers: [Driver] = []
    var stageDrivers: [Driver] = []
    var stagePart: [stageParticipiant] = []
    var stageId: Int?
    var setting = true
    var organizerView = false
    var changeble = false
    var delegate: StageDriversListDelegate?
    var showIndexis: Dictionary<Int, Bool> = [:]
    
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !organizerView || !changeble {
            addOutlet.isHidden = true
        }
        
        for index in 0...((stageDrivers.count ?? 1)-1) {
            showIndexis[index] = true
        }
        
        searchField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc func tablePress(tapGestureRecognizer: UILongPressGestureRecognizer) {
        if setting {
        tableView.setEditing(!tableView.isEditing, animated: true)
        }
        setting = !setting
    }
    
    @IBAction func addDriverAction(_ sender: Any) {
        
        performSegue(withIdentifier: "goToAllDrivers", sender: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if changeble {
        delegate?.setParticipiants(parts: stagePart)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if stageDrivers.count >= showIndexis.count {
            return showIndexis.filter({$0.value}).count
            
        }
       return stageDrivers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath)
        
        
        var indexToTable = 0
        
        var index = 0
        while indexToTable <= indexPath.row {
            if showIndexis[index]! {
                indexToTable += 1
            }
            index += 1
        }
        
        
        
        if organizerView {
            
            cell.textLabel?.text = stageDrivers[index-1].FIO
            print("До: \(stagePart[index-1].serialNumber)")
            stagePart[index-1].serialNumber = index-1
            print("После: \(stagePart[index-1].serialNumber)")
            
            if stagePart[index-1].confirmed {
                cell.detailTextLabel?.text = "Подтвержден"
            } else {
                cell.detailTextLabel?.text = "Не подтвержден"
            }
            
         
            
            let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tablePress(tapGestureRecognizer:)))
            tapGestureRecognizer.minimumPressDuration = 0.5
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(tapGestureRecognizer)
        } else {
            
            cell.textLabel?.text = stageDrivers[index-1].FIO
            cell.detailTextLabel?.text = ""
            
        }
        
       return cell
    }
    
    func GetAllWithoutStaging() -> [Driver]{
        var allDr = allDrivers
        

        for driver1 in stageDrivers {
            for (index,driver2) in allDr.enumerated() {
                if driver1.iddriver == driver2.iddriver {
                    allDr.remove(at: index)
                }
            }
        }
        return allDr
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return changeble
}
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return changeble
}
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    
    
    
    let driver = stageDrivers.remove(at: sourceIndexPath.row)
    stageDrivers.insert(driver, at: destinationIndexPath.row)
    
    let part = stagePart.remove(at: sourceIndexPath.row)
    stagePart.insert(part, at: destinationIndexPath.row)
    
    tableView.reloadData()
    
}
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let delButton = UITableViewRowAction(style: .normal, title: "Удалить", handler: {rowAction, indexPath in
        self.stagePart.remove(at: indexPath.row)
        self.stageDrivers.remove(at: indexPath.row)
        self.tableView.reloadData()
    })
    delButton.backgroundColor = .red
    
    var title = ""
    if stagePart[indexPath.row].confirmed {
        title = "Отменить подтверждение"
    } else {
        title = "Подтвердить"
    }
    
    let confirmButton = UITableViewRowAction(style: .normal, title: title, handler: {rowAction, indexPath in
        self.stagePart[indexPath.row].confirmed = !self.stagePart[indexPath.row].confirmed
        self.tableView.reloadData()
    })
    confirmButton.backgroundColor = .black
    
    return [delButton, confirmButton]
    
}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToAllDrivers" {
            let allDriversViewCont = segue.destination as! DriversTableViewController
        
        allDriversViewCont.drivers = GetAllWithoutStaging()
        allDriversViewCont.choosingMode = true
        allDriversViewCont.addingDriverDelegate = self
        
        
        }
    }
    
    @objc func textFieldDidChange(textfield: UITextField) {
        //print(textfield.text?.uppercased() ?? "")
        if textfield.text?.uppercased() == "" {
            for i in 0...(showIndexis.count-1) {
                showIndexis[i] = true
            }
        } else {
                for (index, driver) in stageDrivers.enumerated() {
                    //print("\(textfield.text?.uppercased() ?? "") в \(driver.FIO.uppercased()) = \(driver.FIO.uppercased().contains(textfield.text?.uppercased() ?? ""))")
                    showIndexis[index] = driver.FIO.uppercased().contains(textfield.text?.uppercased() ?? "")
                }
            
        }
        tableView.reloadData()
    }
    
}

extension StageDriversTableViewController: DriverAddingDelegate {
    func addDriver(withId choosingId: Int?) {
        if let choosingId = choosingId {
            stagePart.append(stageParticipiant(driverId: choosingId, stageId: stageId!))
            
            
            for driver in allDrivers {
                if driver.iddriver == choosingId {
                    stageDrivers.append(driver)
                }
            }
            
            tableView.reloadData()
            
        }
    }
    
    
}
