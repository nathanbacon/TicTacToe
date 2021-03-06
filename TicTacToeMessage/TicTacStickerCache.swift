//
//  TicTacStickerCache.swift
//  TicTacToeMessage
//
//  Created by Nathan Gelman on 2/28/18.
//  Copyright © 2018 Nathan Gelman. All rights reserved.
//

import UIKit
import Messages

class TicTacStickerCache {
    
    static let cache = TicTacStickerCache()
    
    private let cacheURL: URL
    
    private let queue = OperationQueue()
    
    var oneFile: String?
    
    var sticker: MSSticker?
    
    // MARK: Initialization
    private init() {
        let fileManager = FileManager.default
        let tempPath = NSTemporaryDirectory()
        let directoryName = UUID().uuidString
        
        do {
            cacheURL = URL(fileURLWithPath: tempPath).appendingPathComponent(directoryName)
            try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            fatalError("Unable to create cache URL: \(error)")
        }
    }
    
    deinit {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: cacheURL)
        }
        catch {
            print("Unable to remove cache directory: \(error)")
        }
    }
    
    func save(_ fileName: String) {
        let defaults = UserDefaults.standard
        defaults.set(fileName as AnyObject, forKey: "history")
    }
    
    func load() -> String? {
        let defaults = UserDefaults.standard
        
        if let fileName = defaults.object(forKey: "history") as? String {
            oneFile = fileName
        }
        
        return oneFile
    }
    
    // MARK: Functions
    
    func sticker(for ticTacVC: TicTacToeViewController, completion: @escaping (_ sticker: MSSticker) -> Void) {
        guard let model = ticTacVC.ticTacModel else { fatalError() }
        let fileName = model.signature + ".png"
        let url = cacheURL.appendingPathComponent(fileName)
        save(fileName)
        let image = ticTacVC.ticTacView.screenShot
        // Create an operation to process the request.
        let operation = BlockOperation {
            // Check if the sticker already exists at the URL.
            let fileManager = FileManager.default
            guard !fileManager.fileExists(atPath: url.absoluteString) else { return }
            
            // Create the sticker image and write it to disk.
            
            guard let imageData = UIImagePNGRepresentation(image) else { fatalError() }
            
            do {
                try imageData.write(to: url, options: [.atomicWrite])
            } catch {
                fatalError("Failed to write sticker image to cache: \(error)")
            }
        }
        
        // Set the operation's completion block to call the request's completion handler.
        operation.completionBlock = {
            do {
                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "Tic Tac Toe")
                completion(sticker)
            } catch {
                print("Failed to write image to cache, error: \(error)")
            }
        }
        
        // Add the operation to the queue to start the work.
        queue.addOperation(operation)
        
    }
    
    func sticker(for fileName: String, completion: @escaping (_ sticker: MSSticker) -> Void) {
        let url = cacheURL.appendingPathComponent(fileName)
        do {
            let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "Tic Tac Toe")
            completion(sticker)
        } catch {
            print("Failed to write image to cache, error: \(error)")
        }
    }
    

}
