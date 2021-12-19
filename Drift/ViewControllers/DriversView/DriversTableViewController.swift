//
//  DriversTableViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 3.12.21.
//

import UIKit


protocol DriverAddingDelegate: AnyObject {
    func addDriver(withId choosingId: Int?)
}


class DriversTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var drivers: [Driver]?
    var driverForSend: Driver?
    var choosingMode = false
    var choosenId: Int?
    var showIndexis: Dictionary<Int, Bool> = [:]
    
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var driverTable: UITableView!
    
    weak var addingDriverDelegate: DriverAddingDelegate?
    
    @IBAction func addAction(_ sender: Any) {
    
        driverForSend = nil
        performSegue(withIdentifier: "goToOneDriver", sender: self)
    
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0...((drivers?.count ?? 1)-1) {
            showIndexis[index] = true
        }
        
        searchField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        driverTable.dataSource = self
        driverTable.delegate = self
    
        
    }
    
    @objc func textFieldDidChange(textfield: UITextField) {
        //print(textfield.text?.uppercased() ?? "")
        if textfield.text?.uppercased() == "" {
            for i in 0...(showIndexis.count-1) {
                showIndexis[i] = true
            }
        } else {
            if let drivers = drivers {
                for (index, driver) in drivers.enumerated() {
                    //print("\(textfield.text?.uppercased() ?? "") в \(driver.FIO.uppercased()) = \(driver.FIO.uppercased().contains(textfield.text?.uppercased() ?? ""))")
                    showIndexis[index] = driver.FIO.uppercased().contains(textfield.text?.uppercased() ?? "")
                }
            }
        }
        driverTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if choosingMode {
            addButtonOutlet.isHidden = true
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (drivers?.count ?? 0) >= showIndexis.count {
            return showIndexis.filter({$0.value}).count
            
        }
        return drivers?.count ?? 0
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellFromAllDrivers")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellDriver", for: indexPath)
        
        var indexToTable = 0
        
        var index = 0
        while indexToTable <= indexPath.row {
            if showIndexis[index]! {
                indexToTable += 1
            }
            index += 1
        }
        
        
        
        
        cell.textLabel?.text = drivers![index-1].FIO
        cell.detailTextLabel?.text = drivers![index-1].country
        
       
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if choosingMode {
            addingDriverDelegate?.addDriver(withId: drivers![indexPath.row].iddriver)
            self.dismiss(animated: true, completion: nil)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            driverForSend = drivers![indexPath.row]
            performSegue(withIdentifier: "goToOneDriver", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOneDriver" {
            (segue.destination as! OneDriverViewController).driver = driverForSend
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension DriversTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
