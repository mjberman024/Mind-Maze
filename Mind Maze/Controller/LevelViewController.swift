//
//  LevelViewController.swift
//  Mind Maze
//
//  Created by Matthew Berman on 5/24/18.
//  Copyright © 2018 Matthew Berman. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class LevelViewController: UIViewController, GADBannerViewDelegate {

    var idChangeY = 0
    var idChangeX = 0
    var xPosition = 0
    var yPosition = 0
    var timer = Timer()
    var timer60Sec = Timer()
    var levelPath:[String] = []
    var pathShowed:[String] = []
    var userPath:[String] = []
    var levelPathCopy:[String] = []
    var levelType:String = ""
    var directions = ["U","D","L","R"]
    var numMoves:Int = 0
    var numMoveLevelChosen = 0
    var timeStart:Bool = false
    var timeLabel = UILabel()
    var timeRemaining:Int = 0
    var numSolved:Int!
    var numSolvedArray:[Int]!
    var pathSpeedString:String = "Normal"
    var pathSpeedRate:Double = 0.8
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var moveNumLabel: UILabel! = UILabel()
    @IBOutlet var swipes: [UISwipeGestureRecognizer]!
    @IBOutlet var arrowButtons: [UIButton]!
    @IBOutlet weak var pathMover: UIView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var goButton:UIButton!
    @IBOutlet weak var gameViewTitle: UILabel!
    @IBOutlet weak var levelViewBannerAd: GADBannerView!

    
    var howToPlay:HowToPlayView!
    var challengeLevelMenu = ChallengesMenuViewController()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaultsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSettings")
    var userDefaultResults:[Any]!
    var userDefaults:UserSettings!
    
    let userStatsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserStats")
    var userStatsResults:[Any]!
    var userStats:UserStats!
    
    var levelViewInterstitialAd: GADInterstitial!
    var levelsUntilAdAppears = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if levelType == "ChallengeAddOne" {
            gameViewTitle.text = "Add 1"
        }else if(levelType == "Challenge60Sec"){
            gameViewTitle.text = "60 Seconds"
        }else {
            gameViewTitle.text = "Level \(numMoveLevelChosen)"
        }
        
        //Fetching Core Data
        let context = appDelegate.persistentContainer.viewContext
        userDefaultsRequest.returnsObjectsAsFaults = false
        do {
            userDefaultResults = try context.fetch(userDefaultsRequest)
            userDefaults = userDefaultResults[0] as! UserSettings
            pathSpeedString = userDefaults.pathSpeed!
        } catch {
            print("Failed")
        }
        
        userStatsRequest.returnsObjectsAsFaults = false
        do {
            userStatsResults = try context.fetch(userStatsRequest)
            userStats = userStatsResults[0] as! UserStats
            print("Fetched user stats")
            if levelType != "ChallengeAddOne" && levelType != "Challenge60Sec" {
                numSolvedArray = userStats.roundsComplete
            }
        } catch {
            print("Failed")
        }
        
        // end Fetching
        
        if levelType == "Challenge60Sec" {
            timeLabel = UILabel(frame: moveNumLabel.frame)
            timeLabel.transform = CGAffineTransform.identity.translatedBy(x: 75, y: 0)
            moveNumLabel.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(-75), y: 0)
            timeLabel.font = UIFont(name: moveNumLabel.font.fontName, size: moveNumLabel.font.pointSize)
            timeRemaining = 10
            timeLabel.text = "Time: \(timeRemaining)"
            self.view.addSubview(timeLabel)
        }
        
        if pathSpeedString == "Normal" {
            pathSpeedRate = 0.75
        } else if pathSpeedString == "Fast"{
            pathSpeedRate = 0.5
        } else {
            pathSpeedRate = 1.0
        }
        
        if userDefaults.movingChoice == "Swipes" {
            for x in 0...3{
                arrowButtons[x].isHidden = true
            }
        }
        placeButtons()
        setXYtoZero()
//        createLevelPath(levelType)
        replayButton.isHidden = true
        resetButton.isHidden = true
        self.levelPathCopy = levelPath
        for x in 0...3 {
            swipes[x].isEnabled = false
            arrowButtons[x].isEnabled = false
        }
        
        levelViewInterstitialAd = createAndLoadInterstitial()

        levelViewBannerAd.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        levelViewBannerAd.rootViewController = self
        levelViewBannerAd.delegate = self
        levelViewBannerAd.load(GADRequest())
        //goButton.imageView?.image = #imageLiteral(resourceName: "Play")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
//        setXYtoZero()


    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    func placeButtons() {
        if userDefaults.playButtonPosition == "Left" {
            goButton.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(-210), y: 0)
            resetButton.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(210), y: 0)
            replayButton.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(210), y: 0)
        }else {
            goButton.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
            resetButton.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
            replayButton.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        
        levelViewInterstitialAd = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        levelViewInterstitialAd.load(request)
        return levelViewInterstitialAd
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        levelViewInterstitialAd = createAndLoadInterstitial()
    }
    
    
    @IBAction func showAd(_ sender:UIButton) {
        if levelViewInterstitialAd.isReady {
            levelViewInterstitialAd.present(fromRootViewController: self)
        } else {
            print("Ad is not ready")
        }
        levelViewInterstitialAd = createAndLoadInterstitial()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if userDefaults.howToPlayShown == false {
            howToPlay = Bundle.main.loadNibNamed("HowToPlayView", owner: self, options: nil)?.first as? HowToPlayView
            self.view.addSubview(howToPlay)
            howToPlay.frame = CGRect(x: view.center.x - 150, y: view.center.y - 250, width: 300, height: 500)
            howToPlay.backgroundColor = .black
            howToPlay.alpha = 0.8
            howToPlay.setTitle("How To Play")
            userDefaults.setValue(true, forKey: "howToPlayShown")
            
            let panGesture = UIPanGestureRecognizer()
            panGesture.addTarget(self, action: #selector(LevelViewController.handlePan(_:)))
            howToPlay.addGestureRecognizer(panGesture)
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
        
                        howToPlay.removeFromSuperview()
                }
        //print("\(view.superview?.frame.maxX)")
        //        gestureRecognizer.view?.superview?.frame.maxX
    }
    

//    /*Potential feature where the block starts in a random location */
//    func randomizeStart(){
//        let xRand = Int(arc4random_uniform(UInt32(4)))
//        let yRand = Int(arc4random_uniform(UInt32(4)))
//    }
    
    
    /*
     Called from View Did Load.  Creates the path the user is attempting to solve
     xPosition and yPosition are changed
     */
    
    func createLevelPath(_ type:String){
        getPath(numMoveLevelChosen)
        levelPathCopy = levelPath
    }
    /*
     creates the path for the user
     */
    func getPath(_ num:Int){
        var random:Int
        while(levelPath.count < num) {
            random = Int(arc4random_uniform(UInt32(directions.count)))
            let move = directions[random]
            //print("move \(move)")
            
            if (verifyMove(move)) {
                //print("verified\(levelPath.count)")
                updatePosition(move)
                levelPath.append(move)
            }
        }
        print(levelPath)
    }
    /*
     Determines if the move during path creation is valid through a series of checks
     */
    
    func verifyMove(_ move:String) -> Bool {
        if(xPosition == -2 && move == "L") {
            return false
        }else if (yPosition == -2 && move == "D") {
            return false
        }else if((xPosition == -2 && yPosition == -2) && (move != "U" && move != "R")) {
            return false
        }else if(xPosition == 2 && move == "R"){
            return false
        }else if(yPosition == 2 && move == "U"){
            return false
        }else if ((xPosition == 2 && yPosition == 2) && (move != "D" && move != "L")) {
            return false
        }
        else if (levelPath.count > 1 && move == levelPath[levelPath.count - 2]){
            return false
        }
//        else if(levelPath.count > 0 && move == "U" && levelPath[levelPath.count - 1] == "U" && levelType == "hard"){
//            return false
//        }
    else {
            return true
        }
    }
    
    
    @IBAction func replayPath(_ sender: Any) {
        
        goButton.isHidden = true
        resetButton.isHidden = true
        replayButton.isHidden = true
        goButton.setTitle("Done!", for: .normal)
        goButton.setImage(#imageLiteral(resourceName: "Complete"), for: .normal)
        xPosition = 0
        yPosition = 0
        levelPathCopy = pathShowed
        pathShowed = []
        for x in 0...3 {
            swipes[x].isEnabled = false
            arrowButtons[x].isEnabled = false
        }
        //moveToOriginalPosition()
        setXYtoZero()
        pathMover.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        self.pathMover.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(idChangeX), y: CGFloat(idChangeY))
        timer = Timer.scheduledTimer(timeInterval: pathSpeedRate, target: self, selector: #selector(self.moveMazePiece), userInfo: nil, repeats: true)
        
        
    }
    
    
    
    
    @IBAction func showPath(_ sender: Any) {
        //if goButton.imageView?.image == #imageLiteral(resourceName: "Play") {//goButton.titleLabel?.text == "Go!" {
        if goButton.titleLabel?.text == "Go!"{
            createLevelPath(levelType)
            goButton.isHidden = true
            goButton.setTitle("Done!", for: .normal)
            goButton.setImage(#imageLiteral(resourceName: "Complete"), for: .normal)
            xPosition = 0
            yPosition = 0
            pathMover.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            
            if levelType == "Challenge60Sec" && !timeStart{
                timer60Sec = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update60SecTimer), userInfo: nil, repeats: true)
                timeStart = true
            }
            
            timer = Timer.scheduledTimer(timeInterval: pathSpeedRate, target: self, selector: #selector(self.moveMazePiece), userInfo: nil, repeats: true)
            
        }
        else { // When the button is clicked when it says "Done!"
            didUserWin()
            pathMover.backgroundColor = UIColor(red: 64.0/255.0, green: 229.0/255.0, blue: 155.0/255.0, alpha: 1.0)
            resetButton.isHidden = false
        }
    }
    
    @objc func moveMazePiece(){
        if levelPathCopy.count != 0 {
            let dir = levelPathCopy[0]
            if dir == "U"{
                swipeUp(UIButton())
            }
            if dir == "R" {
                swipeRight(UIButton())
            }
            if dir == "D" {
                swipeDown(UIButton())
            }
            if dir == "L" {
                swipeLeft(UIButton())
            }
            print("this is levelPathCopy: \(levelPathCopy)")
            pathShowed.append(levelPathCopy.removeFirst())
            print("pathshowed: \(pathShowed)")
        } else {
            timer.invalidate()
            moveToOriginalPosition()
            userPath.removeAll()
            for x in 0...3 {
                if (userDefaults.movingChoice == "Swipes"){
                    swipes[x].isEnabled = true
                }
                arrowButtons[x].isEnabled = true
            }
            if levelType != "ChallengeAddOne"{
                replayButton.isHidden = false
            }
            pathMover.backgroundColor = UIColor(red: 64.0/255.0, green: 229.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        }
        //moveNumLabel.text = "Moves: \(numMoves)"
    }
    
    @objc func update60SecTimer(){
        if timeRemaining > 0 {
            timeRemaining -= 1
            timeLabel.text = "Time: \(self.timeRemaining)"
        } else {
            for x in 0...3 {
                swipes[x].isEnabled = false
                arrowButtons[x].isEnabled = false
            }
            resetButton.isHidden = true
            replayButton.isHidden = true
            timer60Sec.invalidate()
            
        }
        
        
    }
    
    func moveToOriginalPosition() {
        setXYtoZero()
        self.pathMover.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(idChangeX), y: CGFloat(idChangeY))
        if goButton.isHidden == true {
            goButton.isHidden = false
        }
        resetButton.isHidden = false
    }
    
    /*
     updates the x and y values of the position for the mazeBlock
     */
    func updatePosition(_ move:String) {
        if move == "U" {
            yPosition += 1
        } else if move == "D" {
            yPosition -= 1
        } else if move == "L" {
            xPosition -= 1
        } else if move == "R" {
            xPosition += 1
        }
    }
    
    
    /*
     Swipe directions: Up, Down, Right, Left
     cheeck if the move is within the board
     updates x or y position
     moves the piece
     calls registerUserSwipe
     
     */
    @IBAction func swipeUp(_ sender: Any) {
        if numMoves != 0 {
            if yPosition > -2 {
                yPosition -= 1
                idChangeY = Int(pathMover.bounds.height) * yPosition
                movePiece()
                registerUserSwipe(direction: "U")
            }
        }
    }
    
    @IBAction func swipeDown(_ sender:Any) {
        if numMoves != 0 {
            if yPosition < 2 {
                yPosition += 1
                idChangeY = Int(pathMover.bounds.height) * yPosition
                movePiece()
                registerUserSwipe(direction: "D")
            }
        }
    }
    
    @IBAction func swipeRight(_ sender:Any) {
        if numMoves != 0 {
            if xPosition < 2 {
                xPosition += 1
                idChangeX = Int(pathMover.bounds.width) * xPosition
                movePiece()
                registerUserSwipe(direction: "R")
            }
        }
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        if numMoves != 0 {

            if xPosition > -2 {
                xPosition -= 1
                idChangeX = Int(pathMover.bounds.width) * xPosition
                movePiece()
                registerUserSwipe(direction: "L")
            }
        }
    }
    
    /*
     increses move count
     changes label
     */
    
    func registerUserSwipe(direction:String){
        userPath.append(direction)
        numMoves -= 1
        moveNumLabel.text = "Moves: \(numMoves)"
    }
    
    func didUserWin() {
        if userPath != pathShowed {
            didNotWin()
        } else {
            didWin()
        }
    }
    

    
    @IBAction func resetLevel(_ sender:UIButton!){
        setXYtoZero()
        userPath = []
        moveNumLabel.text = "Moves: \(numMoves)"
        self.pathMover.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(idChangeX), y: CGFloat(idChangeY))
        timer.invalidate()
    }
    
    func movePiece() {
        self.pathMover.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(idChangeX), y: CGFloat(idChangeY))
    }
    
    
    func didNotWin() {
        let tryAgainAlert = UIAlertController(title: "Not Quite!", message: "Try Again", preferredStyle: .alert)
        let youLose = UIAlertAction(title: "Start Over", style: .cancel) { (action) in
            print("Did not win")
            if self.levelType == "ChallengeAddOne" {
                for x in 0...3 {
                    self.swipes[x].isEnabled = false
                    self.arrowButtons[x].isEnabled = false
                }
                self.numMoveLevelChosen = 3
                self.moveToOriginalPosition()
                self.goButton.setTitle("Go!", for: .normal)

                self.goButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
                
                self.pathShowed.removeAll()
                self.levelPath.removeAll()
                self.setXYtoZero()
                self.createLevelPath(self.levelType)
                self.replayButton.isHidden = true
                self.resetButton.isHidden = true
                self.levelPathCopy = self.levelPath
                self.showAd(UIButton())
            } else {
                self.resetLevel(UIButton())
            }
        }
//        let retry = UIAlertAction(title: "Start Over", style: .default) { (action) in
//            self.numMoveLevelChosen = 3
//            //print("HERE")
//        }
//        if levelType == "ChallengeAddOne" {
//            //print("not oops")
//            tryAgainAlert.addAction(retry)
//            //print("oops")
//        }
        print("made it here")
        tryAgainAlert.addAction(youLose)
        present(tryAgainAlert, animated: true, completion: nil)
    }
    
    var randomAdCount:Int!
    
    func nextLevel(_ sender: UIButton!) {
        for x in 0...3 {
            swipes[x].isEnabled = false
            arrowButtons[x].isEnabled = false
        }
        if levelType == "ChallengeAddOne" {
            numMoveLevelChosen += 1
        }
        setXYtoZero()
        userPath.removeAll()
        goButton.setTitle("Go!", for: .normal)
        goButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        goButton.isHidden = false
        resetButton.isHidden = true
        replayButton.isHidden = true //here
        pathMover.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        self.pathMover.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(idChangeX), y: CGFloat(idChangeY))
        levelPath.removeAll()
        pathShowed.removeAll()
        createLevelPath(levelType)
        
        if levelsUntilAdAppears == 0 && levelType != "ChallengeAddOne"{
            showAd(UIButton())
            randomAdCount = Int(arc4random_uniform(UInt32(4))) + 2
            levelsUntilAdAppears = randomAdCount
        }else{
            levelsUntilAdAppears -= 1
        }
    }
    
    func setXYtoZero(){

        xPosition = 0
        yPosition = 0
        idChangeX = xPosition * Int(pathMover.bounds.width)
        idChangeY = yPosition * Int(pathMover.bounds.height)
        numMoves = numMoveLevelChosen
        moveNumLabel.text = "Moves: \(numMoves)"
    }
    
    func didWin() {
        let winnerAlert = UIAlertController(title: "Congrats!", message: "You got the path!", preferredStyle: .alert)
        let youWin = UIAlertAction(title: "Next Level", style: .cancel) { (action) in
            self.nextLevel(UIButton())
        }
        
        if levelType == "ChallengeAddOne"{
            if userStats.addOneRecord < numMoveLevelChosen {
                self.userStats.setValue(Double(self.numMoveLevelChosen), forKey: "addOneRecord")
                self.appDelegate.saveContext()
            }
        }else {
            numSolvedArray[numMoveLevelChosen - 4] += 1
            userStats.setValue(numSolvedArray, forKey: "roundsComplete")
            appDelegate.saveContext()
            
        }
        winnerAlert.addAction(youWin)
        present(winnerAlert, animated: true, completion: nil)
        var memCoins:Int16 = (userStats.memoryCoins as Int16)
        memCoins = memCoins + Int16(numMoveLevelChosen)
        userStats.setValue(memCoins, forKey: "memoryCoins")
        appDelegate.saveContext()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissLevelVC(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        performSegue(withIdentifier: "challengeMenu", sender: sender)
//        if segue.identifier == "challengeMenu" {
//            let destinationController = segue.destination as! ChallengesMenuViewController
//            print("Woo Challenge")
////            if let type = sender as? UIButton{
////                let num = type.titleLabel?.text?.removeFirst()
////                // this only works for 1-9!! Must remove another character for 10+
////                destinationController.numMoveLevelChosen = Int(String(num!))!
////            }
//        }
//        else {
//            print("Level life")
//        }
//        print("here")
        
    }
 

}
