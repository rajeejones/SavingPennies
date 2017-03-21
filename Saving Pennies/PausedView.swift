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

var muteSounds = false
var muteMusic = false

class PausedView: UIView {
    
    @IBOutlet weak var fxButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    weak var pausedViewDelegate: PausedViewDelegate?
    
    var playSounds:Bool = true {
        didSet {
            let fxImage = playSounds ? #imageLiteral(resourceName: "fxButton_Normal"): #imageLiteral(resourceName: "fxButton_Mute")
            fxButton.setImage(fxImage, for: UIControlState.normal)
        }
    }
    var playMusic: Bool = true {
        didSet {
            let musicImage = playMusic ? #imageLiteral(resourceName: "musicButton_Normal") : #imageLiteral(resourceName: "musicButton_Mute")
            musicButton.setImage(musicImage, for: UIControlState.normal)
        }
    }
    override func awakeFromNib() {
        //super.awakeFromNib()
        
        playSounds = !muteSounds
        playMusic = !muteMusic
        
    }
    
    @IBAction func musicButtonPressed(_ sender: UIButton) {
        playMusic = !playMusic
        muteMusic = !playMusic
        pausedViewDelegate?.musicButtonToggled(button: sender)
    }
    
    @IBAction func fxButtonPressed(_ sender: UIButton) {
        playSounds = !playSounds
        muteSounds = !playSounds
        pausedViewDelegate?.fxButtonToggled(button: sender)
    }
    
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
    }
    
}
