//
//  Swap.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 8/20/16.
//  Copyright © 2016 Rajee Jones. All rights reserved.
//

struct Swap: CustomStringConvertible, Hashable {
    let coinA: Coin
    let coinB: Coin
    
    init(coinA: Coin, coinB: Coin) {
        self.coinA = coinA
        self.coinB = coinB
    }
    
    var description: String {
        return "swap \(coinA) with \(coinB)"
    }
    
    var hashValue: Int {
        return coinA.hashValue ^ coinB.hashValue
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.coinA == rhs.coinA && lhs.coinB == rhs.coinB) ||
        (lhs.coinB == rhs.coinA && lhs.coinA == rhs.coinB)
}