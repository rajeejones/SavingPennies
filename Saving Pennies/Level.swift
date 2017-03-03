//
//  Level.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 7/26/16.
//  Copyright © 2016 Rajee Jones. All rights reserved.
//

import Foundation

let NumColumns = 7
let NumRows = 7
let NumLevels = 4

struct Expenses {
    var description: String
    var amount: Int
    var paid: Bool
    init(withExpense:String, value:Int) {
        description = withExpense
        amount = value
        paid = false
    }
}

enum InsuranceType {
    case life, health, property
}

enum Powerup {
    case plus2Moves, plus5Moves, plus10Moves, gain, loss
}

struct Insurance {
    var type:InsuranceType!
    var description:String
    var power:Powerup
}

struct Investment {
    
}

struct Credit {
    
}

class Level {
    /**
        The amount of money to carry on to next level
     */
    var savingsAmount = 0
    /**
        If you lose money by a coin, the amount is first subtracted from this amount
    */
    var emergencySavingsAmount = 0
    /**
        Add moves based on the insurance type when movesleft = 0
     */
    var insurance:Insurance?
    /**
        Money that can be invested
     */
    var investment:Investment?
    /**
        Adds money to bank, but also adds expense until paid off with interest
     */
    var credit:Credit?
    
    
    var levelNumber = 0
    var movesLeft = 0
    var expenses: [Expenses] = [Expenses]()
    var targetScore = 0
    
    var coins: Array2D<Coin> = Array2D<Coin>(columns: NumColumns, rows: NumRows)
    var tiles: Array2D<Tile> = Array2D<Tile>(columns: NumColumns, rows: NumRows)


    public var possibleSwaps = Set<Swap>()
    
    
    init(filename: String) {
        
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) else { return }
        
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        
        for (row, rowArray) in tilesArray.enumerated() {
            
            let tileRow = NumRows - row - 1
    
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
        targetScore = dictionary["targetScore"] as! Int
        movesLeft = dictionary["moves"] as! Int
        let tempExpense = dictionary["expenses"] as! Array<Dictionary<String, AnyObject>>
        for item in tempExpense {
            expenses.append(Expenses(withExpense: item["description"] as! String, value: item["amount"] as! Int))
        }
        
    }
    
        
}

