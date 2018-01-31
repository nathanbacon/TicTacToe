//
//  TicTacToeModel.swift
//  TicTacToe MessagesExtension
//
//  Created by Nathan Gelman on 1/12/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import Foundation

struct TicTacToe {
    
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
    
    static let defaultBoardSize = 3

    var boardSize: Int

    var board: [Array<TicTacMark?>]
    
    private var lastMove: IndexPath?
    
    var isEnabled: Bool
    
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
    
    mutating func commitLastMove() {
        lastMove = nil
    }
    
    func requestData(completion: ((_ data: [[TicTacToe.TicTacMark?]]) -> Void)) {
        completion(board)
    }
    
    func getWin() {
        for col in 0..<boardSize {
            guard let topMark = board[col][0] else { continue }
            for row in 1..<boardSize {
                if topMark != board[col][row] {
                    break
                }
            }
        }
    }
    
    init(from strings: [String?]) {
        let rowLen = Int(sqrt(Float(strings.count)))
        self.init(withSize: rowLen)

        for (index, string) in strings.enumerated() {
            let mark = TicTacMark(from: string)
            
            board[index/rowLen][index%rowLen] = mark
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
    
    init(withSize size: Int = TicTacToe.defaultBoardSize) {
        boardSize = size
        let row: [TicTacMark?] = Array(repeating: nil, count: size)
        board = Array(repeating: row, count: size)
        isEnabled = true
    }
    
    private func printBoard() {
        for row in board {
            var rowStr = ""
            for item in row {
                rowStr += item?.toString ?? "_"
                rowStr += " "
            }
            print(rowStr)
        }
    }
    
}


