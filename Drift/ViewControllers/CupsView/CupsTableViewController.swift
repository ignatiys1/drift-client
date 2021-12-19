//
//  CupsTableViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 3.11.21.
//

import UIKit

class CupsTableViewController: UITableViewController {
    
    var cups: [Cup] = []
    var cupForSend: Cup?
    var canEditCups = true
    
    var userCupOnly = false
    
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    
    @IBAction func addAction(_ sender: Any) {
        cupForSend = nil
        performSegue(withIdentifier: "goToOneCup", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.parent?.parent == nil {
            userCupOnly = true
            Adapter.shared.askForCups(userCupOnly)
            
        }
        
        
        if THIS_USER.type == UserTypes.org.rawValue {
            addButtonOutlet.isEnabled = true
        } else {
            addButtonOutlet.isEnabled = false
        }
        
        cups = [Cup()]
        
        Adapter.shared.delegateCup = self
        
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CupCustomCell") as! CupTableViewCell
        
        let cup = cups[indexPath.section]
        
        cell.cupName?.text = cup.cupName + " \(cup.year)"
        FBClient.shared.getImage(withPath: cup.getImgPath(), imgName: "icon", completion: {image in
            guard let image = image else {
                return
            }
            cell.cupImage?.image = image
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        cupForSend = cups[indexPath.section]
        performSegue(withIdentifier: "goToOneCup", sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOneCup" {
            let destController = segue.destination as! OneCupViewController
            
            if let cupForSend = cupForSend {
                destController.cup = cupForSend
            }
            
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        refreshBegin(newtext: "Refresh",
                     refreshEnd: {(x:Int) -> () in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    func refreshBegin(newtext:String, refreshEnd: @escaping (Int) -> ()) {
        DispatchQueue.global(qos: .default).async(execute: {
            print("refreshing")
            sleep(2)
               
            Connection.shared.reconnect()
            Adapter.shared.askForCups(self.userCupOnly)
            
            DispatchQueue.main.async(execute: {
                refreshEnd(0)
            })
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CupsTableViewController: AdapterDelegateCup {
    func doAnythingWith(cups: [Cup]){
        self.cups = cups
        self.tableView.reloadData()
    }
}

