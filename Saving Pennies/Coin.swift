//
//  Coin.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 7/26/16.
//  Copyright © 2016 Rajee Jones. All rights reserved.
//

import SpriteKit

enum CoinType: Int, CustomStringConvertible {
    case unknown = 0, bag, penny, euro, pound, tag, yen
    
    var spriteName: String {
        let spriteNames = [
            "Bag",
            "Penny",
            "Euro",
            "Pound",
            "Tag",
            "Yen"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> CoinType {
        return CoinType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}

class Coin: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let cointype: CoinType
    var sprite: SKSpriteNode?
    var description: String {
        return "type:\(cointype) square:(\(column),\(row))"
    }
    
    init(column: Int, row: Int, cointype: CoinType) {
        self.column = column
        self.row = row
        self.cointype = cointype
    }
    
    var hashValue: Int {
        return row*10 + column
    }
}

func ==(lhs: Coin, rhs: Coin) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
