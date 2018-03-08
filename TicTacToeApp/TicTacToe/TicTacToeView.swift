//
//  TicTacToeView.swift
//  TicTacToe MessagesExtension
//
//  Created by Nathan Gelman on 1/12/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit

class TicTacToeView: UIView {
    
    private static let lineToViewRatio: CGFloat = 0.90
    
    var boardSize: Int = TicTacToe.defaultBoardSize
    
    lazy var boardArea: CGRect = {
        let sideLength = TicTacToeView.lineToViewRatio * bounds.width
        let sizeOfBoard = CGSize(width: sideLength, height: sideLength)
        let edgeInset = (bounds.width - sideLength) / 2
        let origin = CGPoint(x: edgeInset, y: edgeInset)
        return CGRect(origin: origin, size: sizeOfBoard)
    }()
    
    var edgeInset: CGFloat {
        let sideLength = TicTacToeView.lineToViewRatio * bounds.width
        return (bounds.width - sideLength) / 2
    }
    
    lazy var squares: [[CGRect]] = {
        let blankWidth = (lengthOfBar - barThickness * CGFloat(boardSize - 1)) / CGFloat(boardSize)
        let blankSize = CGSize(width: blankWidth, height: blankWidth)

        var rows: [[CGRect]] = []

        for rowNum in 0..<boardSize {
            var row: [CGRect] = []
            var origin = boardArea.origin
            
            origin.y = boardArea.origin.y + CGFloat(rowNum) * (blankWidth + barThickness)
            for col in 0..<boardSize {
                origin.x = boardArea.origin.x + CGFloat(col) * (blankWidth + barThickness)
                let square = CGRect(origin: origin, size: blankSize)

                row.append(square)
            }
            rows.append(row)
            
        }
        
        return rows
    }()    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear

    }
    
    func drawWin(from start: IndexPath, to end: IndexPath){
        guard start.row < boardSize, start.section < boardSize, start.row >= 0, start.section >= 0,
            end.section < boardSize, end.row < boardSize, end.row >= 0, end.section >= 0  else { return }
        
        let barThickness = self.barThickness * 0.65
        let barLength = (squares[0][boardSize - 1].maxX - squares[0][0].minX)
        if start.row == end.row {
            // this is a horizontal row
            
            let row = squares[start.row]
            let startOrigin = CGPoint(x: row[0].minX, y: row[0].midY - barThickness / 2)
            
            //let endOrigin = CGPoint(x: row[boardSize - 1].maxX, y: row[boardSize-1].midY - barThickness / 2)
            let size = CGSize(width: barLength, height: barThickness)
            let rect = CGRect(origin: startOrigin, size: size)

            let path = UIBezierPath(roundedRect: rect, cornerRadius: 20)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
        } else if start.section == end.section {
            // this is a vertical row
        } else {
            // this is a diagonal
        }
    }
    
    private func createVeritcalBars() {
        let numBars = (boardSize) - 1
        let combinedWidthOfBars = CGFloat(numBars) * barThickness
        let blankSpace = lengthOfBar - combinedWidthOfBars
        let blankRegions: Int = numBars + 1
        let lengthOfBlank = (blankSpace) / CGFloat(blankRegions)

        
        var runningPoint = boardArea.origin
        
        for _ in 0..<(numBars) {
            runningPoint.x += lengthOfBlank
            let rect = CGRect(origin: runningPoint, size: CGSize(width: barThickness, height: lengthOfBar))
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 20)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
            runningPoint.x += barThickness
        }
        
    }
    
    lazy var barThickness: CGFloat = {
        let combinedWidthOfBars = boardArea.width * 0.10
        return combinedWidthOfBars / CGFloat(boardSize - 1)
    }()
    
    lazy var markThickness: CGFloat = {
       return barThickness * 0.50
    }()
    
    var lengthOfBar: CGFloat {
        return bounds.width * TicTacToeView.lineToViewRatio
    }

    
    func syncBoard(with model: [[TicTacToe.TicTacMark?]], forWin winningCoords: (IndexPath, IndexPath)?) {
        boardSize = model.count
        if let subLayers = layer.sublayers {
            for subLayer in subLayers {
                subLayer.removeFromSuperlayer()
            }
        }
        
        createVeritcalBars()
        createHorizontalBars()
        
        var rowIndex = 0
        var colIndex = 0
        for row in model {
            
            for mark in row {
                if let mark = mark {
                    drawPlayer(mark, in: squares[rowIndex][colIndex])
                }
    
                colIndex += 1
            }
  
            rowIndex += 1
            colIndex = 0
        }
        
        if let winningCoords = winningCoords {
            drawWin(from: winningCoords.0, to: winningCoords.1)
        }
    }
    
    private func drawPlayer(_ player: TicTacToe.TicTacMark, in rect: CGRect) {
        if player == .o {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let path = UIBezierPath(arcCenter: center,
                                    radius: rect.width * TicTacToeView.lineToViewRatio / 2.5,
                                    startAngle: 0,
                                    endAngle: 2 * CGFloat.pi,
                                    clockwise: true)
            let circle = CAShapeLayer()
            circle.path = path.cgPath
            circle.strokeColor = UIColor.black.cgColor
            circle.fillColor = nil
            circle.lineWidth = markThickness
            layer.addSublayer(circle)
        } else {
            let origin = CGPoint(x: rect.minX, y: rect.midY - markThickness / 2)
            let size = CGSize(width: rect.width, height: markThickness)
            let rect = CGRect(origin: origin, size: size)
            let leg1Path = UIBezierPath(roundedRect: rect, cornerRadius: 15)

            let leg1 = CAShapeLayer()
            let leg2 = CAShapeLayer()
            leg1.path = leg1Path.cgPath
            leg2.path = leg1Path.cgPath
            leg2.fillColor = UIColor.black.cgColor
            leg2.lineWidth = markThickness
            leg1.fillColor = UIColor.black.cgColor

            leg1.lineWidth = markThickness
            
            layer.addSublayer(leg1)
            layer.addSublayer(leg2)
            let x = rect.midX
            let y = rect.midY
            
            var trans = CATransform3DMakeTranslation(x, y, 0)
            trans = CATransform3DRotate(trans, CGFloat.pi / 4, 0, 0, 1.0)
            trans = CATransform3DTranslate(trans, -1 * x, -1 * y, 0)
            leg1.transform = trans
            trans = CATransform3DMakeTranslation(x, y, 0)
            trans = CATransform3DRotate(trans, CGFloat.pi / 4, 0, 0, -1.0)
            trans = CATransform3DTranslate(trans, -1 * x, -1 * y, 0)
            leg2.transform = trans

        }
    }
    
    private func createHorizontalBars() {
        let numBars = boardSize - 1
        let combinedWidthOfBars = CGFloat(numBars) * barThickness
        let blankSpace = lengthOfBar - combinedWidthOfBars
        let blankRegions: Int = numBars + 1
        let heightOfBlank = (blankSpace) / CGFloat(blankRegions)
        
        var runningPoint = boardArea.origin
        
        for _ in 0..<(numBars) {
            runningPoint.y += heightOfBlank
            let rect = CGRect(origin: runningPoint, size: CGSize(width: lengthOfBar, height: barThickness))
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 20)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
            runningPoint.y += barThickness
        }
    }
    
    func boardLocation(forTouchAt point: CGPoint) -> IndexPath? {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if squares[row][col].contains(point) {
                    return IndexPath(row: row, section: col)
                }
            }
        }
        
        return nil
    }
    
    private func square(at point: CGPoint) -> CGRect? {
        for row in squares {
            for square in row {
                if square.contains(point) {
                    return square
                }
            }
        }
        return nil
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

