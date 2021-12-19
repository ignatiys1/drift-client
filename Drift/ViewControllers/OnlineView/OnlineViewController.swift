//
//  OnlineViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 16.11.21.
//

import UIKit

class OnlineViewController: UIViewController {
    
    var stage: Stage?
    var run: Run?
    
    var solution = 0
    var thisJudgeNum = 0
    
    @IBOutlet weak var onlineLabel: UILabel!
    
    @IBOutlet weak var stageNameView: UILabel!
    @IBOutlet weak var cupNameView: UILabel!
    
    
    @IBOutlet weak var imageFirstDriver: UIImageView!
    @IBOutlet weak var nameFirstDriver: UILabel!
    @IBOutlet weak var carFirstDriver: UILabel!
    @IBOutlet weak var countryFirstDriver: UILabel!
    
    @IBOutlet weak var imageSecondDriver: UIImageView!
    @IBOutlet weak var nameSecondDriver: UILabel!
    @IBOutlet weak var carSecondDriver: UILabel!
    @IBOutlet weak var countrySecondDriver: UILabel!
    
    
    @IBOutlet weak var segmentsOutlet1: UISegmentedControl!
    @IBOutlet weak var segmentsOutlet2: UISegmentedControl!
    @IBOutlet weak var segmentsOutlet3: UISegmentedControl!
    
    @IBOutlet weak var firstJudgeName: UILabel!
    @IBOutlet weak var secondJudgeName: UILabel!
    @IBOutlet weak var thirdJudgeName: UILabel!
    
    
    @IBOutlet weak var fJudgeScore: UITextField!
    @IBOutlet weak var sJudgeScore: UITextField!
    @IBOutlet weak var tJudgeScore: UITextField!
    @IBOutlet weak var allJudgeScore: UITextField!
    
    @IBOutlet weak var fJudgeScoreName: UILabel!
    @IBOutlet weak var sJudgeScoreName: UILabel!
    @IBOutlet weak var tJudgeScoreName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Adapter.shared.delegateOnline = self
        Adapter.shared.getOnline()
        
        imageFirstDriver.clipsToBounds = true
        imageFirstDriver.layer.cornerRadius = 10
        
        imageSecondDriver.clipsToBounds = true
        imageSecondDriver.layer.cornerRadius = 10
        
        stageNameView.isHidden = true;
        cupNameView.isHidden = true;
        
        
        imageFirstDriver.isHidden = true
        nameFirstDriver.isHidden = true
        carFirstDriver.isHidden = true
        countryFirstDriver.isHidden = true
        
        imageSecondDriver.isHidden = true
        nameSecondDriver.isHidden = true
        carSecondDriver.isHidden = true
        countrySecondDriver.isHidden = true
        
        
        segmentsOutlet1.isHidden = true
        segmentsOutlet2.isHidden = true
        segmentsOutlet3.isHidden = true
        
        firstJudgeName.isHidden = true
        secondJudgeName.isHidden = true
        thirdJudgeName.isHidden = true
        
        fJudgeScore.isHidden = true
        sJudgeScore.isHidden = true
        tJudgeScore.isHidden = true
        allJudgeScore.isHidden = true
        
        fJudgeScore.isEnabled = false
        sJudgeScore.isEnabled = false
        tJudgeScore.isEnabled = false
        allJudgeScore.isEnabled = false
        
        
        fJudgeScoreName.isHidden = true
        sJudgeScoreName.isHidden = true
        tJudgeScoreName.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stage = nil
        self.viewDidLoad()
    }
    
    @objc func doubleTapped(tap: UITapGestureRecognizer) {
        if 1...3 ~= thisJudgeNum {
            
            if self.run!.qual {
                
                var send = false
                var score = -1
                switch thisJudgeNum {
                case 1:
                    if run?.firstJudgeSolution == -1 {
                        send = true
                    }
                    let scoreFromField = fJudgeScore.text ?? ""
                    score = Int(scoreFromField) ?? -1
                    fJudgeScore.inputViewController?.setEditing(false, animated: true)
                    
                case 2:
                    if run?.secondJudgeSolution == -1 {
                        send = true
                        
                    }
                    let scoreFromField = sJudgeScore.text ?? ""
                    score = Int(scoreFromField) ?? -1
                    sJudgeScore.inputViewController?.setEditing(false, animated: true)
                    
                case 3:
                    if run?.thirdJudgeSolution == -1 {
                        send = true
                    }
                    let scoreFromField = tJudgeScore.text ?? ""
                    score = Int(scoreFromField) ?? -1
                    tJudgeScore.inputViewController?.setEditing(false, animated: true)
                    
                default:
                    break
                }
                
                if send {
                    solution = score
                    
                    let decision = JudgeDecision(judgeId: THIS_USER.iduser, runId: run!.idstagetable, solution: solution, judgeNum: thisJudgeNum)
                    Adapter.shared.sendDecision(decision)
                    
                }
                
                
            } else {
                let decision = JudgeDecision(judgeId: THIS_USER.iduser, runId: run!.idstagetable, solution: solution, judgeNum: thisJudgeNum)
                
                switch thisJudgeNum {
                case 1:
                    if run?.firstJudgeSolution == -1 {
                        Adapter.shared.sendDecision(decision)
                    }
                    let selected = segmentsOutlet3.selectedSegmentIndex
                    
                    switch selected {
                    case 0:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 1)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 2)
                    case 1:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 0)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 2)
                    case 2:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 0)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 1)
                    default: break
                    }
                    
                case 2:
                    if run?.secondJudgeSolution == -1 {
                        Adapter.shared.sendDecision(decision)
                    }
                    let selected = segmentsOutlet3.selectedSegmentIndex
                    
                    switch selected {
                    case 0:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 1)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 2)
                    case 1:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 0)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 2)
                    case 2:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 0)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 1)
                    default: break
                    }
                    
                case 3:
                    if run?.thirdJudgeSolution == -1 {
                        Adapter.shared.sendDecision(decision)
                    }
                    let selected = segmentsOutlet3.selectedSegmentIndex
                    
                    switch selected {
                    case 0:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 1)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 2)
                    case 1:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 0)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 2)
                    case 2:
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 0)
                        segmentsOutlet3.setEnabled(false, forSegmentAt: 1)
                    default: break
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func segment1Changed(_ sender: Any) {
        if segmentsOutlet1.selectedSegmentIndex == 1 {
            solution = 0
            segmentsOutlet1.setTitle("OMT", forSegmentAt: segmentsOutlet1.selectedSegmentIndex)
        } else {
            if segmentsOutlet1.selectedSegmentIndex == 0 {
                solution = run?.firstDriver.iddriver ?? 0
            } else {
                solution = run?.secondDriver!.iddriver ?? 0
            }
            segmentsOutlet1.setTitle("", forSegmentAt: 1)
            
        }
    }
    @IBAction func segment2Changed(_ sender: Any) {
        if segmentsOutlet2.selectedSegmentIndex == 1 {
            solution = 0
            segmentsOutlet2.setTitle("OMT", forSegmentAt: segmentsOutlet2.selectedSegmentIndex)
        } else {
            if segmentsOutlet2.selectedSegmentIndex == 0 {
                solution = run?.firstDriver.iddriver ?? 0
            } else {
                solution = run?.secondDriver!.iddriver ?? 0
            }
            segmentsOutlet2.setTitle("", forSegmentAt: 1)
            
        }
    }
    @IBAction func segment3Changed(_ sender: Any) {
        if segmentsOutlet3.selectedSegmentIndex == 1 {
            solution = 0
            segmentsOutlet3.setTitle("OMT", forSegmentAt: segmentsOutlet3.selectedSegmentIndex)
        } else {
            if segmentsOutlet3.selectedSegmentIndex == 0 {
                solution = run?.firstDriver.iddriver ?? 0
            } else {
                solution = run?.secondDriver!.iddriver ?? 0
            }
            segmentsOutlet3.setTitle("", forSegmentAt: 1)
            
        }
    }
    
    func CheckIfAllDec() {
        
        if let run = run {
            if run.firstJudgeSolution != -1
                && run.secondJudgeSolution != -1
                && run.thirdJudgeSolution != -1 {
                
                if run.qual {
                    var resultScore = 0
                    resultScore = (run.firstJudgeSolution + run.secondJudgeSolution + run.thirdJudgeSolution)/3
                    
                    allJudgeScore.text = "\(resultScore)"
                    
                } else {
                    var forFirst = 0
                    var forSecond = 0
                    
                    
                    switch run.firstJudgeSolution {
                    case run.firstDriverId:
                        forFirst += 1
                    case run.secondDriverId:
                        forSecond += 1
                    default:
                        break
                    }
                    
                    switch run.secondJudgeSolution {
                    case run.firstDriverId:
                        forFirst += 1
                    case run.secondDriverId:
                        forSecond += 1
                    default:
                        break
                    }
                    
                    switch run.thirdJudgeSolution {
                    case run.firstDriverId:
                        forFirst += 1
                    case run.secondDriverId:
                        forSecond += 1
                    default:
                        break
                    }
                    
                    if forFirst == forSecond {
                        onlineLabel.text = "OMT"
                        onlineLabel.isHidden = false
                        
                        
                        imageFirstDriver.alpha = 0.5
                        nameFirstDriver.alpha = 0.5
                        carFirstDriver.alpha = 0.5
                        countryFirstDriver.alpha = 0.5
                        
                        imageSecondDriver.alpha = 0.5
                        nameSecondDriver.alpha = 0.5
                        carSecondDriver.alpha = 0.5
                        countrySecondDriver.alpha = 0.5
                        
                    } else if forFirst > forSecond {
                        //                        imageFirstDriver.setValue(130, forKey: "Width")
                        //                        imageFirstDriver.setValue(130, forKey: "Height")
                        
                        //                        imageFirstDriver.layer.setValue(130, forKey: "Width")
                        //                        imageFirstDriver.layer.setValue(130, forKey: "Height")
                        
                        imageSecondDriver.layer.borderWidth = CGFloat(10)
                        imageSecondDriver.layer.borderColor = self.view.backgroundColor?.cgColor
                        
                        imageSecondDriver.alpha = 0.5
                        nameSecondDriver.alpha = 0.5
                        carSecondDriver.alpha = 0.5
                        countrySecondDriver.alpha = 0.5
                        
                    } else {
                        
                        imageFirstDriver.layer.borderWidth = CGFloat(10)
                        imageFirstDriver.layer.borderColor = self.view.backgroundColor?.cgColor
                        
                        
                        imageFirstDriver.alpha = 0.5
                        nameFirstDriver.alpha = 0.5
                        carFirstDriver.alpha = 0.5
                        countryFirstDriver.alpha = 0.5
                    }
                }
            }
        }
        
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension OnlineViewController: AdapterDelegateOnline {
    
    func setDecision(_ decision: JudgeDecision) {
        
        
        if decision.idstagetable == run?.idstagetable {
            
            if decision.judgeNum == thisJudgeNum {
                let alert = UIAlertController(title: "Успешно", message: "Решение добавлено", preferredStyle: .actionSheet)
                let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
            
            
            if let run = run {
                if run.qual {
                    switch decision.judgeNum {
                    case 1:
                        fJudgeScore.text = "\(decision.solution)"
                        self.run!.firstJudgeSolution = decision.solution
                        fJudgeScore.isEnabled = false
                    case 2:
                        sJudgeScore.text = "\(decision.solution)"
                        self.run!.secondJudgeSolution = decision.solution
                        sJudgeScore.isEnabled = false
                    case 3:
                        tJudgeScore.text = "\(decision.solution)"
                        self.run!.thirdJudgeSolution = decision.solution
                        sJudgeScore.isEnabled = false
                    default:
                        print()
                    }
                } else {
                    switch decision.judgeNum {
                    case 1:
                        SetSegment(for: segmentsOutlet1, by: decision.solution)
                        self.run!.firstJudgeSolution = decision.solution
                    case 2:
                        SetSegment(for: segmentsOutlet2, by: decision.solution)
                        self.run!.secondJudgeSolution = decision.solution
                    case 3:
                        SetSegment(for: segmentsOutlet3, by: decision.solution)
                        self.run!.thirdJudgeSolution = decision.solution
                    default:
                        print()
                    }
                }
            }
        }
        CheckIfAllDec()
    }
    
    func setRun(run: Run?) {
        //if self.run == nil {
        onlineLabel.text = ""
        onlineLabel.isHidden = true
        
        guard let run = run else {
            return
        }
        
        self.run = run
        
        imageFirstDriver.alpha = 1
        nameFirstDriver.alpha = 1
        carFirstDriver.alpha = 1
        countryFirstDriver.alpha = 1
        
        imageSecondDriver.alpha = 1
        nameSecondDriver.alpha = 1
        carSecondDriver.alpha = 1
        countrySecondDriver.alpha = 1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(tap:)))
        tap.numberOfTapsRequired = 2
        
        if run.qual {
            
            FBClient.shared.getImage(withPath: run.firstDriver.getImgPath(), imgName: "mainImg", completion: {image in
                guard let image = image else {return}
                self.imageFirstDriver.image = image
            })
            
            imageFirstDriver.isHidden = false
            nameFirstDriver.isHidden = false
            carFirstDriver.isHidden = false
            countryFirstDriver.isHidden = false
            
            
            
            fJudgeScore.isHidden = false
            sJudgeScore.isHidden = false
            tJudgeScore.isHidden = false
            allJudgeScore.isHidden = false
            
            fJudgeScoreName.isHidden = false
            sJudgeScoreName.isHidden = false
            tJudgeScoreName.isHidden = false
            
            nameFirstDriver.text = run.firstDriver.FIO
            carFirstDriver.text = run.firstDriver.car
            countryFirstDriver.text = run.firstDriver.country
            if run.firstDriver.city != "" {
                countryFirstDriver.text = run.firstDriver.country + ", " + run.firstDriver.city
            }
            
            fJudgeScoreName.text = run.firstJudge.firstName + "\n" + run.firstJudge.lastName
            sJudgeScoreName.text = run.secondJudge.firstName + "\n" + run.secondJudge.lastName
            tJudgeScoreName.text = run.thirdJudge.firstName + "\n" + run.thirdJudge.lastName
            
            
            if run.firstJudgeSolution != -1 {
                fJudgeScore.text = "\(run.firstJudgeSolution)"
            }
            if run.secondJudgeSolution != -1 {
                sJudgeScore.text = "\(run.secondJudgeSolution)"
            }
            if run.thirdJudgeSolution != -1 {
                tJudgeScore.text = "\(run.thirdJudgeSolution)"
            }
            
            switch THIS_USER.iduser{
            case run.firstJudge.iduser:
                thisJudgeNum = 1
                if run.firstJudgeSolution == -1 {
                    fJudgeScore.isEnabled = true
                    fJudgeScore.addGestureRecognizer(tap)
                }
            case run.secondJudge.iduser:
                thisJudgeNum = 2
                if run.secondJudgeSolution == -1 {
                    sJudgeScore.isEnabled = true
                    sJudgeScore.addGestureRecognizer(tap)
                }
            case run.thirdJudge.iduser:
                thisJudgeNum = 3
                if run.thirdJudgeSolution == -1 {
                    tJudgeScore.isEnabled = true
                    tJudgeScore.addGestureRecognizer(tap)
                }
            default:
                print()
            }
            
        } else {
            
            FBClient.shared.getImage(withPath: run.firstDriver.getImgPath(), imgName: "mainImg", completion: {image in
                guard let image = image else {return}
                self.imageFirstDriver.image = image
            })
            FBClient.shared.getImage(withPath: run.secondDriver!.getImgPath(), imgName: "mainImg", completion: {image in
                guard let image = image else {return}
                self.imageSecondDriver.image = image
            })
            
            imageFirstDriver.isHidden = false
            nameFirstDriver.isHidden = false
            carFirstDriver.isHidden = false
            countryFirstDriver.isHidden = false
            
            imageSecondDriver.isHidden = false
            nameSecondDriver.isHidden = false
            carSecondDriver.isHidden = false
            countrySecondDriver.isHidden = false
            
            
            segmentsOutlet1.isHidden = false
            segmentsOutlet2.isHidden = false
            segmentsOutlet3.isHidden = false
            
            firstJudgeName.isHidden = false
            secondJudgeName.isHidden = false
            thirdJudgeName.isHidden = false
            
            
            
            nameFirstDriver.text = run.firstDriver.FIO
            carFirstDriver.text = run.firstDriver.car
            countryFirstDriver.text = run.firstDriver.country
            if run.firstDriver.city != "" {
                countryFirstDriver.text = run.firstDriver.country + ", " + run.firstDriver.city
            }
            
            nameSecondDriver.text = run.secondDriver!.FIO
            carSecondDriver.text = run.secondDriver!.car
            countrySecondDriver.text = run.secondDriver!.country
            if run.firstDriver.city != "" {
                countrySecondDriver.text = run.secondDriver!.country + ", " + run.secondDriver!.city
            }
            
            print(run.firstJudge.firstName + " " + run.firstJudge.lastName)
            firstJudgeName.text = run.firstJudge.firstName + " " + run.firstJudge.lastName
            secondJudgeName.text = run.secondJudge.firstName + " " + run.secondJudge.lastName
            thirdJudgeName.text = run.thirdJudge.firstName + " " + run.thirdJudge.lastName
            
            
            SetSegment(for: segmentsOutlet1, by: run.firstJudgeSolution, judge: run.firstJudge)
            SetSegment(for: segmentsOutlet2, by: run.secondJudgeSolution, judge: run.secondJudge)
            SetSegment(for: segmentsOutlet3, by: run.thirdJudgeSolution, judge: run.thirdJudge)
            
            
            
            switch THIS_USER.iduser{
            case run.firstJudge.iduser:
                thisJudgeNum = 1
                if run.firstJudgeSolution == -1 {
                    
                    segmentsOutlet1.addGestureRecognizer(tap)
                    
                    segmentsOutlet1.setEnabled(true, forSegmentAt: 0)
                    segmentsOutlet1.setEnabled(true, forSegmentAt: 1)
                    segmentsOutlet1.setEnabled(true, forSegmentAt: 2)
                }
            case run.secondJudge.iduser:
                thisJudgeNum = 2
                if run.secondJudgeSolution == -1 {
                    segmentsOutlet2.addGestureRecognizer(tap)
                    
                    segmentsOutlet2.setEnabled(true, forSegmentAt: 0)
                    segmentsOutlet2.setEnabled(true, forSegmentAt: 1)
                    segmentsOutlet2.setEnabled(true, forSegmentAt: 2)
                }
            case run.thirdJudge.iduser:
                thisJudgeNum = 3
                if run.thirdJudgeSolution == -1 {
                    segmentsOutlet3.addGestureRecognizer(tap)
                    
                    segmentsOutlet3.setEnabled(true, forSegmentAt: 0)
                    segmentsOutlet3.setEnabled(true, forSegmentAt: 1)
                    segmentsOutlet3.setEnabled(true, forSegmentAt: 2)
                }
            default:
                break
            }
        }
        
        CheckIfAllDec()
        
        
        //        } else if self.run?.idstagetable == run.idstagetable {
        //
        //
        //
        //
        //        }
    }
    
    func setStage(stage: Stage) {
        onlineLabel.isHidden = true
        
        self.stage = stage
        
        self.cupNameView.isHidden = false
        self.stageNameView.isHidden = false
        
        self.cupNameView.text = stage.cup?.cupName
        self.stageNameView.text = stage.stageName
    }
    
    func SetSegment(for segment: UISegmentedControl, by solution: Int, judge: User){
        
        switch solution{
        case 0:
            segment.setEnabled(true, forSegmentAt: 1)
            segment.setTitle("OMT", forSegmentAt: 1)
            segment.selectedSegmentIndex = 1
        case run?.firstDriverId:
            segment.setTitle("", forSegmentAt: 1)
            segment.selectedSegmentIndex = 0
        case run?.secondDriverId:
            segment.setTitle("", forSegmentAt: 1)
            segment.selectedSegmentIndex = 2
        default:
            if THIS_USER.iduser == judge.iduser {
                segment.setTitle("OMT", forSegmentAt: 1)
                segment.selectedSegmentIndex = 1
            }
        }
        
    }
    
    func SetSegment(for segment: UISegmentedControl, by solution: Int){
        
        switch solution{
        case 0:
            segment.setEnabled(true, forSegmentAt: 1)
            segment.setTitle("OMT", forSegmentAt: 1)
            segment.selectedSegmentIndex = 1
        case run?.firstDriverId:
            segment.setTitle("", forSegmentAt: 1)
            segment.selectedSegmentIndex = 0
        case run?.secondDriverId:
            segment.setTitle("", forSegmentAt: 1)
            segment.selectedSegmentIndex = 2
        default:
            print()
        }
        
    }
    
    
    
}


