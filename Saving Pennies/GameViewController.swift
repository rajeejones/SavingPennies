//
//  GameViewController.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 7/21/16.
//  Copyright (c) 2016 Rajee Jones. All rights reserved.
//

import UIKit
import SpriteKit

var gameScore = 0
var level: Level!

var currentLevelNum = 0
let formatter = NumberFormatter()


typealias CompletionHandler = ((_ success:Bool) -> Void)?

class GameViewController: UIViewController, BillPaymentDelegate, PausedViewDelegate {
    
    // Mark: Variables
    var scene: GameScene!
    var logicController:LogicController!
    var movesLeft = 0
    var paidExpensesCount = 0
    
    // Mark: Constants

    
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
    @IBOutlet weak var bankButton: UIButton!
    
    @IBOutlet weak var expensesPaidLabel: UILabel!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var expensesRemainingLabel: UILabel!
    
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
        
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
                
        overlayImage.isHidden = true;
        currentLevelNum = 0
        setupLevel(levelNum: currentLevelNum)
        
    }
    
    func setupLevel(levelNum: Int) {
        
        // Configure the view.
        let skView = gameSkView as SKView
        skView.isMultipleTouchEnabled = false
       
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        //scene.backgroundColor = UIColor().UIColorFromHex(rgbValue: 0x4A4A4A)
        scene.scaleMode = .aspectFit
        
        
        level = Level(filename: "Level_\(levelNum)")
        paidExpensesCount = 0
        logicController = LogicController(withLevel: level)
        scene.logicController = logicController
        scene.swipeHandler = handleSwipe
        scene.addTiles()
        
        setupExpenses()
        
        // Present the scene.
        skView.presentScene(scene)
        

        beginGame()
    }
    
    func setupExpenses() {
        expensesTableView.register(UINib(nibName: "ExpenseTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        expensesTableView.delegate = self
        expensesTableView.dataSource = self
        expensesTableView.separatorColor = UIColor.clear
        expensesRemainingLabel.text = "0/\(level.expenses.count)"
        expensesTableView.setContentOffset(CGPoint.zero, animated: true)
        expensesTableView.reloadData()
    }

    func beginGame() {
        scene.animateBeginGame() { }
        movesLeft = level.movesLeft
        gameScore = 0
        updateLabels()
        logicController.resetComboMultiplier()
        shuffle()
    }
    
    func shuffle() {
        
        scene.removeAllCoinSprites()
        let newCoins = logicController.shuffle()
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
                self.setupLevel(levelNum: currentLevelNum)
                
            }
            break
        case .GameOver:
            scene.animateGameOver() {
                print("GAME OVER")
                self.performSegue(withIdentifier: "unwindToCharacterSelect", sender: self)
            }
        default:
            shuffle()
        }
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if logicController.isPossibleSwap(swap) {
            logicController.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
            
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = logicController.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCoins(chains) {
            
            for chain in chains {
                gameScore += chain.score
            }
            self.updateLabels()
            
            let columns = self.logicController.fillHoles()
            self.scene.animateFallingCoins(columns) {
                let columns = self.logicController.topUpCoins()
                self.scene.animateNewCoins(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        logicController.resetComboMultiplier()
        logicController.detectPossibleSwaps()
        
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
        remainingMovesLabel.text = String(format: "%ld", movesLeft)
        bankAmountLabel.text = formatter.string(from: NSNumber(value: gameScore))
        expensesTableView.reloadData()
        
    }
    
    func decrementMoves() {
        
        
        
//        if gameScore >= level.targetScore {
//            goToNextLevel()
//        }
//        else
        if movesLeft <= 1 {
            showOverlay(overlayType: GameViewController.OverlayImageState.GameOver)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                self.hideOverlay(overlayType: GameViewController.OverlayImageState.GameOver)
            }
        } else {
        
        movesLeft -= 1
        updateLabels()
        }
    }
    
    func goToNextLevel() {
        showOverlay(overlayType: GameViewController.OverlayImageState.LevelComplete)
        currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum + 1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            self.hideOverlay(overlayType: GameViewController.OverlayImageState.LevelComplete)
        }
    }
    
    // Mark: Actions
    @IBAction func shuffleButtonPressed(_ sender: UIButton) {
        shuffle()
        decrementMoves()
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
        let xibView = Bundle.main.loadNibNamed("PausedView", owner: nil, options: nil)?[0] as! PausedView
        xibView.pausedViewDelegate = self
        PopupContainer.generatePopupWithView(xibView).show()
    }
    
    @IBAction func bankButtonPressed(_ sender: Any) {
        let xibView = Bundle.main.loadNibNamed("PausedView", owner: nil, options: nil)?[0] as! PausedView
        xibView.pausedViewDelegate = self
        PopupContainer.generatePopupWithView(xibView).show()
    }
    
    
        
    func payBill(forAmount: Int) {
        if (forAmount <= gameScore) {
            gameScore = gameScore - forAmount
            self.updateLabels()
        } else {
            let alert = UIAlertController(title: "Insufficient Funds", message: "You currently dont have enough money in the bank to pay this right now.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func advanceLevel() {
        goToNextLevel()
    }
    
    func musicButtonToggled(button:UIButton) {
        if (!muteMusic) {
            if (!backgroundMusicPlayer.isPlaying) {
                backgroundMusicPlayer.play()
            }
        } else {
            backgroundMusicPlayer.pause()
        }
    }
    
    func exitButtonPressed() {
        self.performSegue(withIdentifier: "unwindToCharacterSelect", sender: self)
    }
    
    func restartButtonPressed() {
        beginGame()
    }
    
}

extension GameViewController: UITableViewDataSource, UITableViewDelegate, PayButtonDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return level.expenses.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        cell = setupExpensesTableViewCell(tableView, indexPath: indexPath)
        
        return cell
        
        
    }
    
    func setupExpensesTableViewCell(_ tableView:UITableView,indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ExpenseTableViewCell
        
        cell.itemLabel.text = level.expenses[indexPath.row].description
        cell.itemLabel.textColor = UIColor.brown
        cell.paid = level.expenses[indexPath.row].paid
        cell.payButtonDelegate = self
        cell.paymentAmount = level.expenses[indexPath.row].amount
        
        if cell.paid {
            cell.payBtn.alpha = 0
            cell.paidCheckmarkImage.alpha = 1
        }
        else if !cell.canBePaid() {
            
            cell.payBtn.borderColor = UIColor.clear
            cell.payBtn.setTitle(formatter.string(from: NSNumber(value: level.expenses[indexPath.row].amount)), for: UIControlState.normal)
            cell.payBtn.tintColor = UIColor.brown
            cell.payBtn.setTitleColor(UIColor.brown, for: UIControlState.normal)
            cell.payBtn.alpha = 1
            cell.paidCheckmarkImage.alpha = 0
            
        } else {
            
            cell.payBtn.borderColor = UIColor().brandGreen()
            cell.payBtn.setTitle("Pay!", for: UIControlState.normal)
            cell.payBtn.tintColor = UIColor().brandGreen()
            cell.payBtn.setTitleColor(UIColor().brandGreen(), for: UIControlState.normal)
            cell.payBtn.alpha = 1
            cell.paidCheckmarkImage.alpha = 0
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    //PayButtonDelegate
    func payButtonPressed(amount: Int, cell: UITableViewCell) {
        // check if paid, then set the variable to paid, and change the image
        
        guard let expenseCell = cell as? ExpenseTableViewCell else {
            return
        }
        
        guard let cellIndex = expensesTableView.indexPath(for: expenseCell)?.row else {
            return
        }
        
        if expenseCell.canBePaid() {
            expenseCell.paid = true
            level.expenses[cellIndex].paid = true
            paidExpensesCount += 1
            expenseCell.animateItemPaid()
            expensesTableView.reloadData()
        }
        
        payBill(forAmount: amount)
        
        var advance = false
        
        for expense in level.expenses {
            if expense.paid {
                advance = true
                
            } else {
                advance = false
                break
            }
        }
        expensesRemainingLabel.text = "\(paidExpensesCount)/\(level.expenses.count)"
        
        if advance {
            //resetExpenses()
            expensesTableView.reloadData()
            advanceLevel()
            
        }
        
    }
    
    func resetExpenses() {
        let numSections = expensesTableView.numberOfSections
        
        for section in 0 ..< numSections {
            let rowCount = expensesTableView.numberOfRows(inSection: section)
            for row in 0 ..< rowCount {
                if let cell = expensesTableView.cellForRow(at: IndexPath(row: row, section: section)) as? ExpenseTableViewCell {
                    cell.reset()
                }
                //let cell = expensesTableView.cellForRow(at: IndexPath(row: row, section: section)) as? ExpenseTableViewCell
            }
        }
    }
}

extension UIColor {
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func brandGreen() -> UIColor {
        return UIColor().UIColorFromHex(rgbValue: 0x1EAA5F)
    }
    
    func brandRed() -> UIColor {
        return UIColor().UIColorFromHex(rgbValue: 0xEA4949)
    }
}
