//
//  MessagesViewController.swift
//  TicTacToeMessage
//
//  Created by Nathan Gelman on 1/31/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    var stickerCache = TicTacStickerCache.cache
    
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        // Use this method to configure the extension and restore previously stored state.
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        removeAllChildViewControllers()
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
        
       presentViewController(for: activeConversation, with: presentationStyle)
    }
    
    // MARK: My Messenger Functions
    
    private func presentViewController(for conversation: MSConversation?, with presentationStyle: MSMessagesAppPresentationStyle) {
        removeAllChildViewControllers()
        var viewController: UIViewController
        
        if(presentationStyle == .expanded) {
            
            let ticTacViewController = TicTacToeViewController()

            ticTacViewController.delegate = self
            
            // MARK: enable message receiving
            var ticTacModel: TicTacToe?
            
            if let message = conversation?.selectedMessage, let url = message.url {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if let queryItems = components?.queryItems {
                    ticTacModel = TicTacToe(from: queryItems)
                }
            }

            ticTacViewController.ticTacModel = ticTacModel ?? TicTacToe(withSize: TicTacToe.defaultBoardSize)
            
            // ENDMARK: End message receiving
            
            
            // MARK: Prevent cheating
            
            if let localID = activeConversation?.localParticipantIdentifier, let remoteID = conversation?.selectedMessage?.senderParticipantIdentifier, ticTacViewController.ticTacModel?.isEnabled == true {
                // uncomment this to make it so one player can make multiple moves
                //ticTacViewController.ticTacModel?.isEnabled = localID != remoteID
            }
            
            // ENDMARK: Prevent cheating

            viewController = ticTacViewController
        } else {
            let boardViewController = GameStickerViewController()
            viewController = boardViewController

        }
        
        configureChildViewController(viewController)
        
    }
    
    func composeMessage(withModel queryItems: [URLQueryItem]?, withImage picture: UIImage?) {
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems
    
        let layout = MSMessageTemplateLayout()
        layout.image = picture
        
        //let message = MSMessage()
        let session = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = MSMessage(session: session)
        
        message.url = urlComponents.url
        message.layout = layout
        
        activeConversation?.insert(message, completionHandler: nil)
    }
    
    // MARK: Helpers
    private func configureChildViewController(_ viewController: UIViewController) {
        addChildViewController(viewController)
        
        viewController.view.frame = view.bounds
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func removeAllChildViewControllers() {
        childViewControllers.forEach {
            $0.willMove(toParentViewController: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParentViewController()
        }
    }

}

extension MessagesViewController: TicTacToeViewControllerDelegate {
    func didCommitMove(with controller: TicTacToeViewController) {
        composeMessage(withModel: controller.ticTacModel?.queryItems, withImage: controller.ticTacView.screenShot)
        if let _ = controller.ticTacModel?.winningCoords {
            stickerCache.sticker(for: controller, completion: {_ in })
        }
        dismiss()
    }
}
