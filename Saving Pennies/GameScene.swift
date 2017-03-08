//
//  GameScene.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 7/21/16.
//  Copyright (c) 2016 Rajee Jones. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var logicController: LogicController!
    var swipeHandler: ((Swap) -> ())?
    var selectionSprite = SKSpriteNode()
    
    var TileWidth: CGFloat = 50
    var TileHeight: CGFloat = 50.0
    
    let gameLayer = SKNode()
    let coinsLayer = SKNode()
    let tilesLayer = SKNode()
    
    let swapSound = SKAction.playSoundFileNamed("Whoosh.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCoinSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCoinSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    fileprivate var swipeFromColumn: Int?
    fileprivate var swipeFromRow: Int?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override func didMove(to view: SKView)
    {
        //self.backgroundColor = SKColor(colorLiteralRed: 92/255, green: 92/255, blue: 92/255, alpha: 0)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)

        coinsLayer.position = layerPosition
        tilesLayer.position = layerPosition
        
        addChild(tilesLayer)
        addChild(coinsLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
        let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    
    func addSpritesForCoins(_ coins: Set<Coin>) {
        for coin in coins {
            let sprite = SKSpriteNode(imageNamed: coin.cointype.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointForColumn(coin.column, row:coin.row)
            coinsLayer.addChild(sprite)
            coin.sprite = sprite
            
            // Give each coin sprite a small, random delay. Then fade them in.
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                        ])
                    ]))
        }
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if logicController.tileAtColumn(column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func startIndexOfSprite(n:Int) -> CGFloat {
        
        let valueA = TileWidth
        print("Value A for int: \(n) is: \(valueA)")
        let valueB = CGFloat(n) * (TileWidth + 10.0)
        print("Value B for int: \(n) is: \(valueB)")
        let valueC = (TileWidth - 10.0)
        print("Value C for int: \(n) is: \(valueC)")
        print("Result Should be: \(valueA + valueB - valueC)\n")
        return valueA + valueB - valueC
        
    }
    
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        guard let touch = touches.first else { return }
        let location = touch.location(in: coinsLayer)
        // 2
        let (success, column, row) = convertPoint(location)
        if success {
            // 3
            if let coin = logicController.coinAtColumn(column, row: row) {
                // 4
                swipeFromColumn = column
                swipeFromRow = row
                showSelectionIndicatorForCoin(coin)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        guard swipeFromColumn != nil else { return }
        
        // 2
        guard let touch = touches.first else { return }
        let location = touch.location(in: coinsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            // 3
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            // 4
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                // 5
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        touchesEnded(touches, with: event)
        
    }
    
    func trySwapHorizontal(_ horzDelta: Int, vertical vertDelta: Int) {
        // 1
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        // 2
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        // 3
        if let toCoin = logicController.coinAtColumn(toColumn, row: toRow),
            let fromCoin = logicController.coinAtColumn(swipeFromColumn!, row: swipeFromRow!) {
            // 4
            if let handler = swipeHandler {
                let swap = Swap(coinA: fromCoin, coinB: toCoin)
                handler(swap)
            }
        }
    }
    
    func animateSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.coinA.sprite!
        let spriteB = swap.coinB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: Duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: Duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        run(swapSound)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.coinA.sprite!
        let spriteB = swap.coinB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: Duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: Duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        run(invalidSwapSound)
    }
    
    func animateMatchedCoins(_ chains: Set<Chain>, completion: @escaping () -> ()) {
        for chain in chains {
            
            // Add this line:
            animateScoreForChain(chain: chain)
            
            for coin in chain.coins {
                if let sprite = coin.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                         withKey:"removing")
                    }
                }
            }
        }
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingCoins(_ columns: [[Coin]], completion: @escaping () -> ()) {
        // 1
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (idx, coin) in array.enumerated() {
                let newPosition = pointForColumn(coin.column, row: coin.row)
                // 2
                let delay = 0.05 + 0.15*TimeInterval(idx)
                // 3
                let sprite = coin.sprite!
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction, fallingCoinSound])]))
            }
        }
        // 6
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateNewCoins(_ columns: [[Coin]], completion: @escaping () -> ()) {
        // 1
        var longestDuration: TimeInterval = 0
        
        for array in columns {
            // 2
            let startRow = array[0].row + 1
            
            for (idx, coin) in array.enumerated() {
                // 3
                let sprite = SKSpriteNode(imageNamed: coin.cointype.spriteName)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                sprite.position = pointForColumn(coin.column, row: startRow)
                coinsLayer.addChild(sprite)
                coin.sprite = sprite
                // 4
                let delay = 0.1 + 0.2 * TimeInterval(array.count - idx - 1)
                // 5
                let duration = TimeInterval(startRow - coin.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                // 6
                let newPosition = pointForColumn(coin.column, row: coin.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.05),
                            moveAction,
                            addCoinSound])
                        ]))
            }
        }
        // 7
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
        
    func showSelectionIndicatorForCoin(_ coin: Coin) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = coin.sprite {
            let texture = SKTexture(imageNamed: coin.cointype.highlightedSpriteName)
            selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
            selectionSprite.run(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()]))
    }
    
    func animateGameOver(completion: @escaping () -> ()) {
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: completion)
        completion()
    }
    
    func animateBeginGame(completion: @escaping () -> ()) {
        gameLayer.isHidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: completion)
    }
    
    func removeAllCoinSprites() {
        coinsLayer.removeAllChildren()
    }
    
    func animateScoreForChain(chain: Chain) {
        // Figure out what the midpoint of the chain is.
        let firstSprite = chain.firstCoin().sprite!
        let lastSprite = chain.lastCoin().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        // Add a label for the score that slowly floats up.
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 20
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        coinsLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
}
