//
//  TicTacToeViewController.swift
//  TicTacToe MessagesExtension
//
//  Created by Nathan Gelman on 1/12/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit

class TicTacToeViewController: UIViewController {
    
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
    
    var delegate: TicTacToeViewControllerDelegate?
    
    private func updateBoard() {
        ticTacModel?.requestData(completion: ticTacView.syncBoard(with: ))
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: ticTacView)
        guard let path = ticTacView.boardLocation(forTouchAt: location) else { return }
        if(ticTacModel?.makeMove(at: path) ?? false) {
            updateBoard()
        }
        
    }
    
    @objc private func handleCommit() {
        ticTacModel?.commitLastMove()
        delegate?.didCommitMove(with: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ticTacView = TicTacToeView()
        addCommitButton()
        ticTacModel = ticTacModel ?? TicTacToe(withSize: TicTacToe.defaultBoardSize)
 
        //updateBoard()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        ticTacView.addGestureRecognizer(tapGestureRecognizer)
        ticTacView.isUserInteractionEnabled = true
    }
    
    private func addCommitButton() {
        let button = UIButton(type: .system)

        button.backgroundColor = UIColor.green
        button.setTitle("Commit", for: .normal)
        
        button.addTarget(delegate, action: #selector(handleCommit), for: UIControlEvents.touchUpInside)
        
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

protocol TicTacToeViewControllerDelegate {
    func didCommitMove(with controller: TicTacToeViewController)
}

extension UIView {
    var screenShot: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image
    }
}

