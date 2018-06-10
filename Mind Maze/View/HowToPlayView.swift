//
//  howToPlayView.swift
//  Mind Maze
//
//  Created by Matthew Berman on 6/2/18.
//  Copyright © 2018 Matthew Berman. All rights reserved.
//

import UIKit

class HowToPlayView: UIView {
    
    
    @IBOutlet weak var titleLabel = UILabel()
    @IBOutlet weak var swipeToExit = UILabel()
    
    func setTitle(_ title:String) {
        titleLabel?.text = title
    }
    
    func setExitLabel(_ text:String){
        swipeToExit?.text = text
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
