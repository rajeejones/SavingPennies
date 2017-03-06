//
//  CharacterSelectionViewController.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 11/20/16.
//  Copyright © 2016 Rajee Jones. All rights reserved.
//

import UIKit
import AVFoundation

var backgroundMusicPlayer = AVAudioPlayer()

func playBackgroundMusic(filename: String) {
    let url = Bundle.main.url(forResource: filename, withExtension: nil)
    guard let newURL = url else {
        print("Could not find file: \(filename)")
        return
    }
    do {
        backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        backgroundMusicPlayer.volume = 0.7
    } catch let error as NSError {
        print(error.description)
    }
}

class CharacterSelectionViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMusic(filename: "Mining by Moonlight.mp3")
        // Do any additional setup after loading the view.
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
    
    @IBAction public func unwindToCharacterSelectViewController(_ sender: UIStoryboardSegue) {
    }


}
