//
//  GameStickerViewController.swift
//  TicTacToeMessage
//
//  Created by Nathan Gelman on 3/8/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit
import Messages

class GameStickerViewController: UIViewController {
    
    var stickerView: MSStickerView!
    
    private let stickerCache = TicTacStickerCache.cache

    override func viewDidLoad() {
        super.viewDidLoad()
        stickerView = MSStickerView(frame:view.frame)
        stickerView.backgroundColor = UIColor.green
        func prep(for sticker: MSSticker?) {
            stickerView?.sticker = sticker
        }
        stickerCache.load()
        if let fileName = stickerCache.oneFile {
            stickerCache.sticker(for: fileName, completion: prep(for: ))
        }
        
        if let stickerView = stickerView {
            view.addSubview(stickerView)
            
            stickerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                stickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stickerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75, constant: 0),
                stickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75, constant: 0),
                stickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
                ])
            
            view.layoutIfNeeded()
            stickerView.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
