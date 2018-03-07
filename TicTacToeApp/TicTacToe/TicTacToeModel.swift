//
//  TicTacToeModel.swift
//  TicTacToe MessagesExtension
//
//  Created by Nathan Gelman on 1/12/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import Foundation

struct TicTacToe {
    
    static let defaultBoardSize = 3
    
    // MARK: Public API
    
    var isEnabled: Bool

    var boardSize: Int
    
    var winningCoords: (IndexPath, IndexPath)?

    var board: [Array<TicTacMark?>]
    
    mutating func commitLastMove() -> Bool {
        if lastMove == nil {
            return false
        } else {
            lastMove = nil
            return true
        }
    }
    
    mutating func makeMove(at indexPath: IndexPath) -> Bool {
        guard board[indexPath.row][indexPath.section] == nil, let currentPlayer = currentPlayer else { return false }
        
        if let lastMove = lastMove {
            board[lastMove.row][lastMove.section] = nil
        }
        
        lastMove = indexPath
        board[indexPath.row][indexPath.section] = currentPlayer
        return true
    }
    
    func requestData(completion: ((_ data: [[TicTacToe.TicTacMark?]]) -> Void)) {
        completion(board)
    }
    
    // intializes a board from a one-dimensial array of size n*n where n is the length of a row
    init?(from strings: [String?]) {
        let rowLen = Int(sqrt(Float(strings.count)))
        guard rowLen*rowLen == strings.count else { return nil }
        self.init(withSize: rowLen)
        
        for (index, string) in strings.enumerated() {
            let mark = TicTacMark(from: string)
            
            board[index/rowLen][index%rowLen] = mark
        }
    }
    
    // initialize an empty board
    init(withSize size: Int = TicTacToe.defaultBoardSize) {
        boardSize = size
        let row: [TicTacMark?] = Array(repeating: nil, count: size)
        board = Array(repeating: row, count: size)
        isEnabled = true
    }
    
    // ENDMARK: Public API
    
    // MARK: Internal functions
    
    private var lastMove: IndexPath?
    
    private var currentPlayer: TicTacToe.TicTacMark? {
        guard isEnabled else { return nil }
        
        if let lastMove = lastMove {
            return board[lastMove.row][lastMove.section]
        }
        
        var xCount: Int = 0
        var oCount: Int = 0
        for row in board {
            for mark in row {
                if mark == .x {
                    xCount += 1
                } else if mark == .o {
                    oCount += 1
                }
            }
        }
        
        return oCount >= xCount ? .x : .o
    }
    
    var isWin: Bool {
        mutating get {
            func computeLine(rowIterator: @escaping (Int) -> Int, colIterator: @escaping (Int) -> Int, startingAt start: IndexPath) -> Bool {
                func comp(cur: IndexPath) -> Bool {
                    guard cur.row < boardSize, cur.section < boardSize, let curVal = board[cur.row][cur.section] else { return false }
                    let nextRow = rowIterator(cur.row)
                    let nextCol = colIterator(cur.section)
                    
                    if (nextRow == boardSize) || (nextCol == boardSize) {
                        // reached the end of the row or column, no more to compute and it hasn't failed thus far so return true
                        return true
                    } else if nextRow < boardSize, nextCol < boardSize, let nextVal = board[nextRow][nextCol] {
                        // if the two values are equal, recurse, else false
                        return curVal == nextVal ? comp(cur: IndexPath(row: nextRow, section: nextCol)) : false
                    } else {
                        return false
                    }
                }
                
                return comp(cur: start)
            }
            
            for n in 0..<boardSize {
                // compute horizontal row
                if computeLine(rowIterator: {$0}, colIterator: {$0 + 1}, startingAt: IndexPath(row: n, section: 0)) {
                    winningCoords = (IndexPath(row: n, section: 0), IndexPath(row: n, section: boardSize - 1))
                    print("win here")
                    return true
                }
                // compute vertical rows
                if computeLine(rowIterator: {$0 + 1}, colIterator: {$0}, startingAt: IndexPath(row: 0, section: n)) {
                    winningCoords = (IndexPath(row: 0, section: n), IndexPath(row: boardSize - 1, section: n))
                    
                    return true
                }
            }
            
            // compute top left to bottom right
            if computeLine(rowIterator: {$0 + 1}, colIterator: {$0 - 1}, startingAt: IndexPath(row: 0, section: 0)) {
               
                winningCoords = (IndexPath(row: 0, section: 0), IndexPath(row: boardSize - 1, section: boardSize - 1))
                return true
            }
            
            // compute bottom left to to top right
            if computeLine(rowIterator: {$0 - 1}, colIterator: {$0 + 1}, startingAt: IndexPath(row: boardSize - 1, section: 0)) {
                winningCoords = (IndexPath(row: boardSize - 1, section: 0), IndexPath(row: 0, section: boardSize - 1))
                return true
            }
            
            return false
        }

    }
    
    enum TicTacMark {
        case x
        case o
        
        init?(from value: String?) {
            switch value {
            case "o"?:
                self = .o
            case "x"?:
                self = .x
            default:
                return nil
            }
        }
        
        var toString: String {
            get {
                switch self {
                case .o:
                    return "o"
                case .x:
                    return "x"
                }
            }
        }
    }
    
}



