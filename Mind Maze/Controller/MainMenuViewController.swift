//
//  MenuViewController.swift
//  Tipsy Turn
//
//  Created by Matthew Berman on 5/23/18.
//  Copyright © 2018 Matthew Berman. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class MainMenuViewController: UIViewController, GADBannerViewDelegate {

    //var fetchResultController: NSFetchedResultsController<UserSettings>!
    
    @IBOutlet weak var challengeMenuButton: UIButton!
    
    var settingsController:SettingsViewController!
    
    @IBOutlet weak var homeScreenBannerAd: GADBannerView!
    
    let requestStats = NSFetchRequest<NSFetchRequestResult>(entityName: "UserStats")
    let requestSettings = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSettings")
    var resultSettings:[Any]!
    var resultsStats:[Any]!
    override func viewDidLoad() {
        super.viewDidLoad()
        //challengeMenuButton.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        requestSettings.returnsObjectsAsFaults = false
        requestStats.returnsObjectsAsFaults = false
        
        do {
            resultSettings = try context.fetch(requestSettings)
            if resultSettings.count == 0 {
                let settingsEntity = NSEntityDescription.entity(forEntityName: "UserSettings", in: context)
                let statsEntity = NSEntityDescription.entity(forEntityName: "UserStats", in: context)
                let newUser = NSManagedObject(entity: settingsEntity!, insertInto: context)
                let newStats = NSManagedObject(entity: statsEntity!, insertInto: context)
                
                print(newUser)
                setDefaults(newUser)
                blankStats(newStats)
                appDelegate.saveContext()
            }
            for data in resultSettings as! [NSManagedObject] {
                if let firstTime = data.value(forKey: "newPlayer") {
                    print("firstTime \(firstTime as! Bool)")
                    print("not new player")
                    
                    /*
                        After initial release, for new Keys in core data, you must set values here.  Nil values will cause app to crash!
                     */
                    
                } else {
                    
                }
            }
        } catch {
            print("Failed")
        }
        homeScreenBannerAd.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        homeScreenBannerAd.rootViewController = self
        homeScreenBannerAd.load(GADRequest())
        homeScreenBannerAd.delegate = self
    }
    
    //Google ad delegate methods
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    //end of delegate methods
    
    
    func setDefaults(_ user:NSManagedObject) {
        user.setValue(false, forKey: "newPlayer")
        user.setValue("Swipes", forKey: "movingChoice")
        user.setValue("Normal", forKey: "pathSpeed")
        user.setValue("Right", forKey: "playButtonPosition")
        user.setValue(false, forKey: "howToPlayShown")
        user.setValue(false, forKey: "levelUnlockScreenShown")
    }
    
    func blankStats(_ user:NSManagedObject) {
        let roundsComplete = [0,0,0,0,0,0]
        let levelsLocked = [true, true, true, true, true, true]
        user.setValue(roundsComplete, forKey: "roundsComplete")
        user.setValue(levelsLocked, forKey: "levelsLocked")
        user.setValue(0, forKey: "addOneRecord")
        user.setValue(198, forKey: "memoryCoins")
        user.setValue(0, forKey: "sixtySecRecord")
        
    }
    
    @IBAction func shareApp(_ sender: Any) {
        
        let defaultText = "Mind Maze - a new game to test your memory. Give it a try!"
        
        //TODO: CHANGE URL BEFORE RELEASE - to mind maze appstore page
        
        let url = NSURL(string: "https://itunes.apple.com/us/developer/matt-berman/id1217679604?mt=8")! as URL
        let activityViewController = UIActivityViewController(activityItems: [defaultText,url], applicationActivities: nil)//UIActivityViewController(activityItems: items, applicationActivities: nil)

//                activityViewController.popoverPresentationController?.sourceView = sender
//                activityViewController.popoverPresentationController?.sourceRect = sender.bounds
                activityViewController.excludedActivityTypes = [ UIActivityType.postToVimeo, UIActivityType.postToFlickr]
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
    }
    
//    func share(button:UIButton)
//    {
//        guard let imageToShare = imageViewShare.image else
//        {
//            return
//        }
//
//        let items = [ imageToShare ]
//        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
//
//        // Handle iPad and anchor the activity controller to the button
//        activityViewController.popoverPresentationController?.sourceView = button
//        activityViewController.popoverPresentationController?.sourceRect = button.bounds
//
//        // Optional: Exclude some activity types just to illustrate how
//        activityViewController.excludedActivityTypes = [ UIActivityType.postToVimeo, UIActivityType.postToFlickr]
//
//        // present the view controller
//        self.present(activityViewController, animated: true, completion: nil)
//    }
    
    
    @IBAction func returnToMainMenu (segue:UIStoryboardSegue) {
        if segue.identifier == "MainMenu" {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

