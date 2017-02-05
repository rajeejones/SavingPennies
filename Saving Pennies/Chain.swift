//
//  Chain.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 8/20/16.
//  Copyright © 2016 Rajee Jones. All rights reserved.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    var coins = [Coin]()
    var score = 0
    
    enum ChainType: CustomStringConvertible {
        case horizontal
        case vertical
        case ltype
        case ttype
        
        var description: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            case .ltype: return "Ltype"
            case .ttype: return "Ttype"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addCoin(_ coin: Coin) {
        coins.append(coin)
    }
    
    func firstCoin() -> Coin {
        return coins[0]
    }
    
    func lastCoin() -> Coin {
        return coins[coins.count - 1]
    }
    
    var length: Int {
        return coins.count
    }
    
    var description: String {
        return "type:\(chainType) coins:\(coins)"
    }
    
    var hashValue: Int {
        return coins.reduce (0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.coins == rhs.coins
}
