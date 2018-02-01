//
//  Extensions.swift
//  TicTacToeMessage
//
//  Created by Nathan Gelman on 1/31/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit

extension UIView {
    var screenShot: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image
    }
}

extension TicTacToe {
    init(from queryItems: [URLQueryItem]) {
        
        var strings = Array<String?>(repeating: nil, count: queryItems.count)
        
        for item in queryItems {
            
            guard let index = Int(item.name), let value = item.value, value == "x" || value == "o" else { continue }
            
            strings[index] = value
            
        }
        
        self.init(from: strings)
 
    }
    
    var queryItems: [URLQueryItem] {
        get {
            var index: Int = 0
            var queryItems: [URLQueryItem] = []
            
            for row in board {
                for mark in row {
                    let queryItem = URLQueryItem(name: String(index), value: mark?.toString ?? "_")
                    queryItems.append(queryItem)
                    index += 1
                }
            }
            
            return queryItems
        }
    }
}
