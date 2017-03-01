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
    
    init(withExpense:String, value:Int) {
        description = withExpense
        amount = value
    }
}

class Level {
    var coins: Array2D<Coin> = Array2D<Coin>(columns: NumColumns, rows: NumRows)
    var tiles: Array2D<Tile> = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    var targetScore = 0
    var maximumMoves = 0
    var expenses: [Expenses] = [Expenses]()
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
        maximumMoves = dictionary["moves"] as! Int
        let tempExpense = dictionary["expenses"] as! Array<Dictionary<String, AnyObject>>
        for item in tempExpense {
            expenses.append(Expenses(withExpense: item["description"] as! String, value: item["amount"] as! Int))
        }
        
    }
    
        
}

