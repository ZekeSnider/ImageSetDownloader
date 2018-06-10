//
//  SplitTraining.swift
//  ImageSetDownloader
//
//  Created by Zeke Snider on 6/5/18.
//  Copyright © 2018 Zeke Snider. All rights reserved.
//

import Foundation


class SplitTraining {
    private let testingDirName = "Testing Data"
    private let trainingDirName = "Training Data"
    private let dsStoreName = ".DS_Store"
    
    private func createTrainingTestingFolders(for localURL: URL) {
        
    }
    
    private func copyOut(from folders: [URL], to parentFolderDirectory: URL) {
        let myFileManager = FileManager.default
        
        for folder in folders {
            let invalidPaths = [dsStoreName]
            guard !invalidPaths.contains(folder.lastPathComponent) else {
                continue
            }
            
            let thisOriginalDir = parentFolderDirectory.appendingPathComponent(folder.lastPathComponent, isDirectory: true)
            try! myFileManager.createDirectory(at: thisOriginalDir, withIntermediateDirectories: true, attributes: nil)
            
            let imageURLs: [URL] = try! myFileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            
            for image in imageURLs {
                let newImageLocation = thisOriginalDir.appendingPathComponent(image.lastPathComponent, isDirectory: false)
                
                try! myFileManager.moveItem(at: image, to: newImageLocation)
                
            }
            
            try! myFileManager.removeItem(at: folder)
        }
    }
    
    
    func combineDirectory() {
        let myFileManager = FileManager.default
        let parentFolderDirectory = URL(fileURLWithPath: "/Users/zeke/Desktop/test")
        let trainingDirectory = parentFolderDirectory.appendingPathComponent(trainingDirName, isDirectory: true)
        let testingDirectory = parentFolderDirectory.appendingPathComponent(testingDirName, isDirectory: true)
        
        let testingFolders: [URL] = try! myFileManager.contentsOfDirectory(at: testingDirectory, includingPropertiesForKeys: nil)
        let trainingFolders: [URL] = try! myFileManager.contentsOfDirectory(at: trainingDirectory, includingPropertiesForKeys: nil)
        
        
        self.copyOut(from: testingFolders, to: parentFolderDirectory)
        self.copyOut(from: trainingFolders, to: parentFolderDirectory)
        
        try! myFileManager.removeItem(at: testingDirectory)
        try! myFileManager.removeItem(at: trainingDirectory)
    }
    
    func splitDirectory() {
        let myFileManager = FileManager.default
        let parentFolderDirectory = URL(fileURLWithPath: "/Users/zeke/Desktop/test")
        let trainingDirectory = parentFolderDirectory.appendingPathComponent(trainingDirName, isDirectory: true)
        let testingDirectory = parentFolderDirectory.appendingPathComponent(testingDirName, isDirectory: true)
        
        let fileURLs: [URL] = try! myFileManager.contentsOfDirectory(at: parentFolderDirectory, includingPropertiesForKeys: nil)
        
        for file in fileURLs {
            let invalidPaths = [testingDirName, trainingDirName, dsStoreName]
            guard !invalidPaths.contains(file.lastPathComponent) else {
                continue
            }
            
            let thisTrainingDir = trainingDirectory.appendingPathComponent(file.lastPathComponent, isDirectory: true)
            let thisTestingDir = testingDirectory.appendingPathComponent(file.lastPathComponent, isDirectory: true)
            
            try! myFileManager.createDirectory(at: thisTrainingDir, withIntermediateDirectories: true, attributes: nil)
            try! myFileManager.createDirectory(at: thisTestingDir, withIntermediateDirectories: true, attributes: nil)
            
            var imageURLs: [URL] = try! myFileManager.contentsOfDirectory(at: file, includingPropertiesForKeys: nil)
            
            imageURLs.shuffle()
            
            
            let imageSplitLocation = Int(round(Double(imageURLs.count) * 0.8))
            
            for (index, image) in imageURLs.enumerated() {
                let thisFileNewLocation: URL!
                if (index <= imageSplitLocation - 1) {
                    thisFileNewLocation = thisTrainingDir.appendingPathComponent(image.lastPathComponent, isDirectory: false)
                } else {
                    thisFileNewLocation = thisTestingDir.appendingPathComponent(image.lastPathComponent, isDirectory: false)
                }
                
                try! myFileManager.moveItem(at: image, to: thisFileNewLocation)
                
                print(thisFileNewLocation)
            }
            
            try! myFileManager.removeItem(at: file)
            
            print()
        }
        
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}
