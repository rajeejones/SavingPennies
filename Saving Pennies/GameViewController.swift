//
//  GameViewController.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 7/21/16.
//  Copyright (c) 2016 Rajee Jones. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {
    
    // Mark: Variables
    var scene: GameScene!
    var level: Level!
    var movesLeft = 0
    var score = 0
    var currentLevelNum = 0
    
    // Mark: Constants
    let formatter = NumberFormatter()
    
    enum OverlayImageState {
        case GameOver, Shuffling, LevelComplete
    }
    
    // Mark: Outlets

    @IBOutlet weak var dueMessageLabel: UILabel!
    @IBOutlet weak var remainingMovesLabel: UILabel!
    @IBOutlet weak var bankAmountLabel: UILabel!
    @IBOutlet weak var gameContainerView: UIView!
    @IBOutlet weak var gameSkView: SKView!
    @IBOutlet weak var overlayImage: UIImageView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var expensesButton: UIButton!
    // Mark: View Overrides
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }  
    }
    
    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLevel(levelNum: currentLevelNum)

    }
    
    func setupLevel(levelNum: Int) {
        overlayImage.isHidden = true;
        
        //        self.view = gameSkView
        // Configure the view.
        let skView = gameSkView as SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        //scene.backgroundColor = UIColor().UIColorFromHex(rgbValue: 0x4A4A4A)
        scene.scaleMode = .aspectFill
        
        level = Level(filename: "Level_\(levelNum)")
        scene.level = level
        scene.swipeHandler = handleSwipe
        
        // Present the scene.
        skView.presentScene(scene)
        
        
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        
        beginGame()
    }
    
    // Mark: Functions
    func beginGame() {
        scene.animateBeginGame() { }
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        shuffle()
    }
    
    func shuffle() {
        
        scene.removeAllCoinSprites()
        let newCoins = level.shuffle()
        scene.addSpritesForCoins(newCoins)
    }
    
    func showOverlay(overlayType: OverlayImageState) {
        switch overlayType {
        case .LevelComplete:
            overlayImage.image = #imageLiteral(resourceName: "LevelCompleteOverlay")
            break
        case .Shuffling:
            overlayImage.image = #imageLiteral(resourceName: "ShufflingOverlay")
            break
        case .GameOver:
            overlayImage.image = #imageLiteral(resourceName: "GameOverOverlay")
            break
        }
        overlayImage.isHidden = false
        scene.isUserInteractionEnabled = false
    }
    
    func hideOverlay(overlayType: OverlayImageState) {
        overlayImage.isHidden = true
        scene.isUserInteractionEnabled = true
        
        switch overlayType {
        case .LevelComplete:
            scene.animateGameOver() {
                self.setupLevel(levelNum: self.currentLevelNum)
                
            }
            break
        case .GameOver:
            scene.animateGameOver() {
                print("GAME OVER")
            }
        default:
            shuffle()
        }
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
            
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCoins(chains) {
            
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingCoins(columns) {
                let columns = self.level.topUpCoins()
                self.scene.animateNewCoins(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        
        if level.possibleSwaps.count < 1 {
            showOverlay(overlayType: OverlayImageState.Shuffling)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                self.hideOverlay(overlayType: OverlayImageState.Shuffling)
            }
            
        }
        view.isUserInteractionEnabled = true
        decrementMoves()
    }
    
    func updateLabels() {
        remainingMovesLabel.text = String(format: "%ld", movesLeft) + " moves"
        bankAmountLabel.text = formatter.string(from: NSNumber(value: score))
        
    }
    
    func decrementMoves() {
        
        if score >= level.targetScore {
            showOverlay(overlayType: GameViewController.OverlayImageState.LevelComplete)
            self.currentLevelNum = self.currentLevelNum < NumLevels ? self.currentLevelNum + 1 : 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                self.hideOverlay(overlayType: GameViewController.OverlayImageState.LevelComplete)
            }
        }
        else if movesLeft <= 1 {
            showOverlay(overlayType: GameViewController.OverlayImageState.GameOver)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                self.hideOverlay(overlayType: GameViewController.OverlayImageState.GameOver)
            }
        } else {
        
        movesLeft -= 1
        updateLabels()
        }
    }
    
    // Mark: Actions
    @IBAction func shuffleButtonPressed(_ sender: UIButton) {
        shuffle()
        decrementMoves()
    }
    
    @IBAction func expensesButtonPressed(_ sender: Any) {
        self.present(TabPopupViewController(), animated: true, completion: nil)
    }
    
    
    

    
}

extension UIColor {
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
