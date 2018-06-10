//
//  LevelMenuViewController.swift
//  Tipsy Turn
//
//  Created by Matthew Berman on 5/24/18.
//  Copyright © 2018 Matthew Berman. All rights reserved.
//

import UIKit
import CoreData

class LevelMenuViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserStats")
    let requestSettings = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSettings")
    var stats:[Any]!
    var user:UserStats!
    var userSettings:UserSettings!
    var memCoins:Int16!
    var roundsSolved:[Int]!
    var lockedLevels:[Bool]!
    var minLevel:Int = 4
    @IBOutlet weak var memCoinCount: UILabel!
    @IBOutlet var levelSolved: [UILabel]!
    @IBOutlet var levelGameTitles: [UIButton]!
    @IBOutlet var levelGameLocks: [UIButton]!
    
    var levelUnlockView:LevelUnlockView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let context = appDelegate.persistentContainer.viewContext
        request.returnsObjectsAsFaults = false
        do {
            stats = try context.fetch(request)
            user = stats[0] as! UserStats
            roundsSolved = user.roundsComplete
            lockedLevels = user.levelsLocked
            memCoinCount.text = "\(user.memoryCoins)"
            memCoins = user.memoryCoins
//            user.levelsLocked = Array(repeating: true, count: 6) as NSObject
//            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
        
        requestSettings.returnsObjectsAsFaults = false
        do {
            let userDefaultResults = try context.fetch(requestSettings)
            userSettings = userDefaultResults[0] as! UserSettings
            //pathSpeedString = userDefaults.pathSpeed!
        } catch {
            print("Failed")
        }
        
        for x in 0...lockedLevels.count-1 {
            let gameTitle = levelGameTitles[x]
            if !lockedLevels[x] {
                levelGameLocks[x].setImage(#imageLiteral(resourceName: "unlock"), for: .normal)//imageView?.image = UIImage(named: "unlock")
                gameTitle.isEnabled = true
                levelGameLocks[x].isEnabled = false

                gameTitle.setTitleColor(UIColor(red: 229.0/255.0, green: 135.0/255.0, blue: 79.0/255.0, alpha: 1), for: .normal)
            } else {
                levelGameLocks[x].setImage(#imageLiteral(resourceName: "locked"), for: .normal)//levelGameLocks[x].imageView?.image = UIImage(named: "locked")
                gameTitle.isEnabled = false
                gameTitle.setTitleColor(.black, for: .normal)
                gameTitle.alpha = 0.5
                levelGameLocks[x].isEnabled = true

            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        memCoinCount.text = "\(String(user.memoryCoins))"
        roundsSolved = user.roundsComplete
        lockedLevels = user.levelsLocked
        memCoins = user.memoryCoins

        for num in 0...roundsSolved.count-1 {
            levelSolved[num].text = "\(roundsSolved[num])"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !userSettings.levelUnlockScreenShown {
        
            print("Adding subview")
            levelUnlockView = Bundle.main.loadNibNamed("LevelUnlockView", owner: self, options: nil)?.first as? LevelUnlockView
            self.view.addSubview(levelUnlockView)
            levelUnlockView.frame = CGRect(x: view.center.x - 150, y: view.center.y - 250, width: 300, height: 550)
            levelUnlockView.backgroundColor = .black
            levelUnlockView.alpha = 0.8
            //levelUnlockView.setTitle("How To Play")
            userSettings.setValue(true, forKey: "levelUnlockScreenShown")

            let panGesture = UIPanGestureRecognizer()
            panGesture.addTarget(self, action: #selector(LevelMenuViewController.handlePan(_:)))
            levelUnlockView.addGestureRecognizer(panGesture)
            appDelegate.saveContext()
        }
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        if( gestureRecognizer.state == .ended) {
            print("We outcha")
            levelUnlockView.removeFromSuperview()
        }
    }
    
    @IBAction func displayUnlockNeeds(_ sender: UIButton) {
        let senderID = sender.restorationIdentifier
        var numMove:Int = 0 //Should be numMove - 4
        var price:Int = 0
        if senderID == "4Move" {
            price = 100
            numMove = 0
            handleUnlock(levelNum: numMove, price: price)
        } else if senderID == "5Move" {
            price = 100
            numMove = 1
            handleUnlock(levelNum: numMove, price: price)
        } else if senderID == "6Move" {
            price = 200
            numMove = 2
            handleUnlock(levelNum: numMove, price: price)
        } else if senderID == "7Move" {
            price = 300
            numMove = 3
            handleUnlock(levelNum: numMove, price: price)
        } else if senderID == "8Move" {
            price = 400
            numMove = 4
            handleUnlock(levelNum: numMove, price: price)
        } else if senderID == "9Move" {
            price = 500
            numMove = 5
            handleUnlock(levelNum: numMove, price: price)
        }
    }
    
    func handleUnlock(levelNum:Int, price:Int){
        if user.memoryCoins >= price {
            let memCoinUnlock = UIAlertController(title: "Unlock \(levelNum + minLevel) Moves for \(price) Memory Coins?", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Unlock", style: .default) { (action) in
                self.unlockLevel(levelNum, price: price)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            memCoinUnlock.addAction(ok)
            memCoinUnlock.addAction(cancel)
            present(memCoinUnlock, animated: true, completion: nil)
        }
        else{
            let insufficient = UIAlertController(title: "You need \(price) Memory Coins to unlock this level!", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            insufficient.addAction(ok)
            present(insufficient, animated: true, completion: nil)
            
        }
    }
    
    func unlockLevel(_ levelNum:Int,price:Int) {
        self.levelGameLocks[levelNum].setImage(#imageLiteral(resourceName: "unlock"), for: .normal)
        self.levelGameTitles[levelNum].isEnabled = true
        self.levelGameTitles[levelNum].alpha = 1.0
        self.levelGameTitles[levelNum].setTitleColor(UIColor(red: 229.0/255.0, green: 135.0/255.0, blue: 79.0/255.0, alpha: 1), for: .normal)
        self.lockedLevels[levelNum] = false
        self.levelGameLocks[levelNum].isEnabled = false
        self.memCoins = self.memCoins - Int16(price)
        self.memCoinCount.text = "\(self.memCoins!)"
        self.user.setValue(self.memCoins, forKey: "memoryCoins")
        self.user.setValue(self.lockedLevels, forKey: "levelsLocked")
        self.appDelegate.saveContext()
    }
    
    @IBAction func returnToLevelMenu (segue:UIStoryboardSegue) {
        if segue.identifier == "LevelMenu" {
            print("In levelMenuVC, ")
            dismiss(animated: true, completion: nil)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        if segue.identifier == "gameView" {
            let destinationController = segue.destination as! LevelViewController
            if let type = sender as? UIButton{
                let num = type.titleLabel?.text?.first//.removeFirst()
                // this only works for 1-9!! Must remove another character for 10+
                destinationController.numMoveLevelChosen = Int(String(num!))!
            }
        }

    }
    
}
