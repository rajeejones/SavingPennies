//
//  PausedView.swift
//  Saving Pennies
//
//  Created by Rajee Jones on 3/14/17.
//  Copyright © 2017 Rajee Jones. All rights reserved.
//

import UIKit

protocol PausedViewDelegate:class {
    func musicButtonToggled(button:UIButton)
    func fxButtonToggled(button:UIButton)
    func exitButtonPressed()
}

var playSounds = true
var playMusic = true

class PausedView: UIView {
    
    @IBOutlet weak var fxButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    weak var pausedViewDelegate: PausedViewDelegate?
    
    override func awakeFromNib() {
        //super.awakeFromNib()
        
        let fxImage = playSounds ? #imageLiteral(resourceName: "fxButton_Normal"): #imageLiteral(resourceName: "fxButton_Normal")
        let musicImage = playMusic ? #imageLiteral(resourceName: "musicButton_Normal") : #imageLiteral(resourceName: "musicButton_Normal")
        
        fxButton.setImage(fxImage, for: UIControlState.normal)
        musicButton.setImage(musicImage, for: UIControlState.normal)
        
    }
    
    @IBAction func musicButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func fxButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
    }
    
    func toggleMusicButton() {
        
    }
    
    func toggleFxButton() {
        
    }
}
