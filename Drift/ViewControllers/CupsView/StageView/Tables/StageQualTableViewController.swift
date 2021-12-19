//
//  StageQualTableViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 6.12.21.
//

import UIKit

class StageQualTableViewController: UITableViewController {

    var thisRuns: [Run] = []
    var stage: Stage?
    var runForUpdating: Run?
    
    var organizerView = false
    var changeble = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Adapter.shared.delegateRuns = self
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        guard let stage = stage else {
            return
        }

        Adapter.shared.getStageRuns(for: stage)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let stage = stage else {
            return 0
        }
        if stage.status == 1 {
            return thisRuns.count/3
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stage = stage else {
            return 0
        }
        if stage.status == 1 {
            return 3
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RunCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RunCell", for: indexPath)

        let numOfRun = ((indexPath.section+1)*3-(2-indexPath.row))-1
        
//        FBClient.shared.getImage(withPath: runs[numOfRun].firstDriver.getImgPath(), imgName: "icon", completion: {image in
//            if let image = image {
//                cell.imageView?.image = image
//            }
//        })
        
        
        print("Секция: \(indexPath.section), строка: \(indexPath.row)")
        print("Заезд в массиве: \(numOfRun)")
        
        print(thisRuns[numOfRun].firstDriver.FIO)
        
        
        cell.textLabel?.text = thisRuns[numOfRun].firstDriver.FIO
        cell.detailTextLabel?.text = "Попытка: \(thisRuns[numOfRun].attempt)"
        
        switch thisRuns[numOfRun].status {
        case 1:
            print("Зеленый")
            cell.backgroundColor = .green
        case 2...3:
            print("Красный")
            cell.backgroundColor = .red
        default:
            print("Белый")
            break
        }
        
        print("_______________________________")
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return organizerView
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var title = ""
        var color = UIColor.green
        let numOfRun = ((indexPath.section+1)*3-(2-indexPath.row))-1
        
        if thisRuns[numOfRun].qual {
            
            switch thisRuns[numOfRun].status {
            
            case 1:
                title = "Завершить заезд"
                color = .red
            case 2...3:
                title = "Решение"
                color = .yellow
            default:
                title = "Начать заезд"
            }
            
            
            
        } else {
            
        }
        
        let actionBut = UITableViewRowAction(style: .normal, title: title, handler: {rowAction, indexPath in
            let numOfRun = ((indexPath.section+1)*3-(2-indexPath.row))-1
            self.runForUpdating = self.thisRuns[numOfRun]
            
            if self.runForUpdating!.status == 0 || self.runForUpdating!.status == 1 {
                self.runForUpdating!.status += 1
                Adapter.shared.setRunStatus(for: self.runForUpdating!)
            }
            
        })
        
        actionBut.backgroundColor = color
        
        return [actionBut]
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}


extension StageQualTableViewController: AdapterDelegateRuns{
    func setStatus(runs: [Run]?) {
        if runs != nil {
            self.thisRuns = runs!
            self.runForUpdating = nil
            self.dismiss(animated: true, completion: nil)
            //self.tableView.reloadData()
        } else {
            Adapter.shared.setRunStatus(for: runForUpdating!)
        }
    }
    
}
