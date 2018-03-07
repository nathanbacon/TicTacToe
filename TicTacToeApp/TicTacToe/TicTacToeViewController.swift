//
//  TicTacToeViewController.swift
//  TicTacToe MessagesExtension
//
//  Created by Nathan Gelman on 1/12/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit

// MARK: Explain that the messagesViewController is the delegate of the this VC
protocol TicTacToeViewControllerDelegate {
    func didCommitMove(with controller: TicTacToeViewController)
}

class TicTacToeViewController: UIViewController {
    
    // the delegate is who cares when a move is made
    // in our case, the delegate is the messagesViewController
    var delegate: TicTacToeViewControllerDelegate?
    
    var ticTacView: TicTacToeView! {
        didSet {
            guard ticTacView != nil else { return }
            
            view.addSubview(ticTacView)

            ticTacView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                ticTacView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ticTacView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -10),
                ticTacView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -10),
                ticTacView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
                ])

            view.layoutIfNeeded()
            ticTacView.layoutIfNeeded()
            updateBoard()

        }
    }
    
    var ticTacModel: TicTacToe? {
        didSet {
            updateBoard()
        }
    }
    
    private func updateBoard() {
        if let ticTacView = ticTacView, let ticTacModel = ticTacModel {
            ticTacModel.requestData(completion: ticTacView.syncBoard(with: ))
            
        }
    }
    
    @objc private func handleCommit() {
        if ticTacModel?.commitLastMove() ?? false {
            delegate?.didCommitMove(with: self)
            if ticTacModel?.isWin == true, let coords = ticTacModel?.winningCoords {
                print("trying to draw win at \(coords)!")
                let start = coords.0
                let end = coords.1
                ticTacView.drawWin(from: start, to: end)
            }
        }
    }

    // MARK: unneccessary to explain
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: ticTacView)
        guard let path = ticTacView.boardLocation(forTouchAt: location) else { return }
        if(ticTacModel?.makeMove(at: path) ?? false) {
            updateBoard()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ticTacView = TicTacToeView()
        addCommitButton()
        ticTacModel = ticTacModel ?? TicTacToe(withSize: TicTacToe.defaultBoardSize)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        ticTacView.addGestureRecognizer(tapGestureRecognizer)
        ticTacView.isUserInteractionEnabled = true
    }
    
    private func addCommitButton() {
        let button = UIButton(type: .system)

        button.backgroundColor = UIColor.green
        button.setTitle("Commit", for: .normal)
        
        button.addTarget(self, action: #selector(handleCommit), for: UIControlEvents.touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: ticTacView.bottomAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalTo: ticTacView.widthAnchor)
            ])
        
        button.layoutIfNeeded()

    }

}




