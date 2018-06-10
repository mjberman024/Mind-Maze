//
//  AboutViewController.swift
//  Tipsy Turn
//
//  Created by Matthew Berman on 5/23/18.
//  Copyright © 2018 Matthew Berman. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    var howToPlay:HowToPlayView!
    var levelUnlockView:LevelUnlockView!

    var launchedView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //launchedView = UIView()
    }
    


    @IBOutlet weak var playInstructions: UIButton!
    
    @IBAction func showHowToPlayScreen(_ sender: Any) {
        howToPlay = Bundle.main.loadNibNamed("HowToPlayView", owner: self, options: nil)?.first as? HowToPlayView
        launchedView = howToPlay

        self.view.addSubview(howToPlay)
        howToPlay.frame = CGRect(x: view.center.x - 150, y: view.center.y - 240, width: 300, height: 500)
        howToPlay.backgroundColor = .black
        howToPlay.setTitle("How To Play")

        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(AboutViewController.handlePan(_:)))
        howToPlay.addGestureRecognizer(panGesture)
    }
    
    @IBAction func showLevelInfoScreen (_ sender: UIButton){
        levelUnlockView = Bundle.main.loadNibNamed("LevelUnlockView", owner: self, options: nil)?.first as? LevelUnlockView
        launchedView = levelUnlockView

        self.view.addSubview(levelUnlockView)
        levelUnlockView.frame = CGRect(x: view.center.x - 150, y: view.center.y - 250, width: 300, height: 550)
        levelUnlockView.backgroundColor = .black
        levelUnlockView.setLevelMenuTextView()
    
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(AboutViewController.handlePan(_:)))
        levelUnlockView.addGestureRecognizer(panGesture)
    
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        if( gestureRecognizer.state == .ended) {
            
            launchedView.removeFromSuperview()
        }
        //print("\(view.superview?.frame.maxX)")
        //        gestureRecognizer.view?.superview?.frame.maxX
    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
////        let panGesture = UIPanGestureRecognizer()
////        panGesture.addTarget(self, action: #selector(LevelViewController.handlePan(_:)))
////        howToPlay.addGestureRecognizer(panGesture)
//    }
    

    @IBOutlet weak var otherApps: UIButton!
    @IBAction func launchAppStore(_ sender: Any) {
        UIApplication.shared.open(NSURL(string: "https://itunes.apple.com/us/developer/matt-berman/id1217679604?mt=8")! as URL, options: [:], completionHandler: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
