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

class Level {
    var coins: Array2D<Coin> = Array2D<Coin>(columns: NumColumns, rows: NumRows)
    var tiles: Array2D<Tile> = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    var targetScore = 0
    var maximumMoves = 0
    public var possibleSwaps = Set<Swap>()
    fileprivate var comboMultiplier = 0
    
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
    }
    
    func coinAtColumn(_ column: Int, row: Int) -> Coin? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return coins[column, row]
    }
    
    func shuffle() -> Set<Coin> {
        var set: Set<Coin>
        repeat {
            set = createInitialCoins()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }
    
    fileprivate func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    
    fileprivate func createInitialCoins() -> Set<Coin> {
        var set = Set<Coin>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                // 2
                var coinType: CoinType
                    repeat {
                        coinType = CoinType.random()
                    } while (column >= 2 &&
                        coins[column - 1, row]?.cointype == coinType &&
                        coins[column - 2, row]?.cointype == coinType)
                        || (row >= 2 &&
                            coins[column, row - 1]?.cointype == coinType &&
                            coins[column, row - 2]?.cointype == coinType)
                
                // 3
                let coin = Coin(column: column, row: row, cointype: coinType)
                coins[column, row] = coin
                
                
                // 4
                set.insert(coin)
                }
            }
        }
        return set
    }
    
    func tileAtColumn(_ column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func performSwap(_ swap: Swap) {
        let columnA = swap.coinA.column
        let rowA = swap.coinA.row
        let columnB = swap.coinB.column
        let rowB = swap.coinB.row
        
        coins[columnA, rowA] = swap.coinB
        swap.coinB.column = columnA
        swap.coinB.row = rowA
        
        coins[columnB, rowB] = swap.coinA
        swap.coinA.column = columnB
        swap.coinA.row = rowB
    }
    
    fileprivate func hasChainAtColumn(_ column: Int, row: Int) -> Bool {
        let coinType = coins[column, row]?.cointype
        
        // Horizontal chain check
        var horzLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && coins[i, row]?.cointype == coinType {
            i -= 1
            horzLength += 1
        }
        
        // Right
        i = column + 1
        while i < NumColumns && coins[i, row]?.cointype == coinType {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 { return true }
        
        // Vertical chain check
        var vertLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && coins[column, i]?.cointype == coinType {
            i -= 1
            vertLength += 1
        }
        
        // Up
        i = row + 1
        while i < NumRows && coins[column, i]?.cointype == coinType {
            i += 1
            vertLength += 1
        }
        return vertLength >= 3
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let coin = coins[column, row] {
                    
                    // Is it possible to swap this coin with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a coin in this spot? If there is no tile, there is no coin.
                        if let other = coins[column + 1, row] {
                            // Swap them
                            coins[column, row] = other
                            coins[column + 1, row] = coin
                            
                            // Is either coin now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                set.insert(Swap(coinA: coin, coinB: other))
                            }
                            
                            // Swap them back
                            coins[column, row] = coin
                            coins[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = coins[column, row + 1] {
                            coins[column, row] = other
                            coins[column, row + 1] = coin
                            
                            // Is either coin now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                set.insert(Swap(coinA: coin, coinB: other))
                            }
                            
                            // Swap them back
                            coins[column, row] = coin
                            coins[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        //let lChains = detectLtypeMatches()
        
        removeCoins(horizontalChains)
        removeCoins(verticalChains)
        //removeCoins(lChains)
//        print("L type matches: \(lChains)")
        
        calculateScores(chains:horizontalChains)
        calculateScores(chains:verticalChains)
        //calculateScores(chains:lChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    func fillHoles() -> [[Coin]] {
        var columns = [[Coin]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Coin]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && coins[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let coin = coins[column, lookup] {
                            // 4
                            coins[column, lookup] = nil
                            coins[column, row] = coin
                            coin.row = row
                            // 5
                            array.append(coin)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpCoins() -> [[Coin]] {
        var columns = [[Coin]]()
        var coinType: CoinType = .unknown
        
        for column in 0..<NumColumns {
            var array = [Coin]()
            
            // 1
            var row = NumRows - 1
            while row >= 0 && coins[column, row] == nil {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newCoinType: CoinType
                    repeat {
                        newCoinType = CoinType.random()
                    } while newCoinType == coinType
                    coinType = newCoinType
                    // 4
                    let coin = Coin(column: column, row: row, cointype: coinType)
                    coins[column, row] = coin
                    array.append(coin)
                }
                
                row -= 1
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    fileprivate func removeCoins(_ chains: Set<Chain>) {
        for chain in chains {
            for coin in chain.coins {
                coins[coin.column, coin.row] = nil
            }
        }
    }
    
    fileprivate func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            var column = 0
            while column < NumColumns-2 {
                // 3
                if let coin = coins[column, row] {
                    let matchType = coin.cointype
                    // 4
                    if coins[column + 1, row]?.cointype == matchType &&
                        coins[column + 2, row]?.cointype == matchType {
                        // 5
                        let chain = Chain(chainType: .horizontal)
                        repeat {
                            chain.addCoin(coins[column, row]!)
                            column += 1
                        } while column < NumColumns && coins[column, row]?.cointype == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }    
                // 6
                column += 1
            }
        }
        return set
    }
    
    fileprivate func detectLtypeMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for indexRow in 0..<NumRows {
            var row = indexRow
            var column = indexRow
            while column < NumColumns-2 && row < NumRows-2 {
                // 3
                if let coin = coins[column, row] {
                    let matchType = coin.cointype
                    // 4
                    if coins[column + 1, row]?.cointype == matchType &&
                        coins[column, row + 1]?.cointype == matchType {
                        // 5
                        let chain = Chain(chainType: .ltype)
                        repeat {
                            chain.addCoin(coins[column, row]!)
                            column += 1
                            row += 1
                        } while column < NumColumns && row < NumRows && coins[column, row]?.cointype == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                // 6
                column += 1
                row += 1
            }
        }
        return set
    }

    fileprivate func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            var row = 0
            while row < NumRows-2 {
                if let coin = coins[column, row] {
                    let matchType = coin.cointype
                    
                    if coins[column, row + 1]?.cointype == matchType &&
                        coins[column, row + 2]?.cointype == matchType {
                        let chain = Chain(chainType: .vertical)
                        repeat {
                            chain.addCoin(coins[column, row]!)
                            row += 1
                        } while row < NumRows && coins[column, row]?.cointype == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }    
                row += 1
            }
        }
        return set
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
}

