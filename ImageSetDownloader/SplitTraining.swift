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
    private let trainingTestingSplit = 0.8
    
    //Copy contents of the from folders to folders of the same number under
    //the to folder
    private func copyOut(from folders: [URL], to parentFolderDirectory: URL) {
        let myFileManager = FileManager.default
        
        for folder in folders {
            let invalidPaths = [dsStoreName]
            guard !invalidPaths.contains(folder.lastPathComponent) else {
                continue
            }
            
            //Get path of where the folder would be located without testing/training subfolders, create the dir
            let thisOriginalDir = parentFolderDirectory.appendingPathComponent(folder.lastPathComponent, isDirectory: true)
            try! myFileManager.createDirectory(at: thisOriginalDir, withIntermediateDirectories: true, attributes: nil)
            
            //Get all the images in this folder
            let imageURLs: [URL] = try! myFileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            
            //Move each of the images
            for image in imageURLs {
                let newImageLocation = thisOriginalDir.appendingPathComponent(image.lastPathComponent, isDirectory: false)
                try! myFileManager.moveItem(at: image, to: newImageLocation)
            }
            
            //Remove the empty folder
            try! myFileManager.removeItem(at: folder)
        }
    }
    
    public func combine(directory: String) {
        let myFileManager = FileManager.default
        let parentFolderDirectory = URL(fileURLWithPath: directory)
        let trainingDirectory = parentFolderDirectory.appendingPathComponent(trainingDirName, isDirectory: true)
        let testingDirectory = parentFolderDirectory.appendingPathComponent(testingDirName, isDirectory: true)
        
        let testingFolders: [URL] = try! myFileManager.contentsOfDirectory(at: testingDirectory, includingPropertiesForKeys: nil)
        let trainingFolders: [URL] = try! myFileManager.contentsOfDirectory(at: trainingDirectory, includingPropertiesForKeys: nil)
        
        self.copyOut(from: testingFolders, to: parentFolderDirectory)
        self.copyOut(from: trainingFolders, to: parentFolderDirectory)
        
        try! myFileManager.removeItem(at: testingDirectory)
        try! myFileManager.removeItem(at: trainingDirectory)
    }
    
    public func split(directory: String) {
        let myFileManager = FileManager.default
        let parentFolderDirectory = URL(fileURLWithPath: directory)
        let trainingDirectory = parentFolderDirectory.appendingPathComponent(trainingDirName, isDirectory: true)
        let testingDirectory = parentFolderDirectory.appendingPathComponent(testingDirName, isDirectory: true)
        
        let folderURLs: [URL] = try! myFileManager.contentsOfDirectory(at: parentFolderDirectory, includingPropertiesForKeys: nil)
        
        for folder in folderURLs {
            //Skip if this is an invalid filename
            let invalidPaths = [testingDirName, trainingDirName, dsStoreName]
            guard !invalidPaths.contains(folder.lastPathComponent) else {
                continue
            }
            
            //Create testing/training subfolders for this folder
            let thisTrainingDir = trainingDirectory.appendingPathComponent(folder.lastPathComponent, isDirectory: true)
            let thisTestingDir = testingDirectory.appendingPathComponent(folder.lastPathComponent, isDirectory: true)
            try! myFileManager.createDirectory(at: thisTrainingDir, withIntermediateDirectories: true, attributes: nil)
            try! myFileManager.createDirectory(at: thisTestingDir, withIntermediateDirectories: true, attributes: nil)
            
            var imageURLs: [URL] = try! myFileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            
            //Shuffle the array and determine the split point for how many files to copy to test/training
            //The array is shuffled to ensure that the testing/training sets are randomized from the data set
            imageURLs.shuffle()
            let imageSplitLocation = Int(round(Double(imageURLs.count) * trainingTestingSplit))
            
            //Loop over all images
            for (index, image) in imageURLs.enumerated() {
                //If this is before the split point, move the file to the training dir, otherwise
                //copy to the testing dir.
                let thisFileNewLocation: URL!
                if (index <= imageSplitLocation - 1) {
                    thisFileNewLocation = thisTrainingDir.appendingPathComponent(image.lastPathComponent, isDirectory: false)
                } else {
                    thisFileNewLocation = thisTestingDir.appendingPathComponent(image.lastPathComponent, isDirectory: false)
                }
                
                try! myFileManager.moveItem(at: image, to: thisFileNewLocation)
            }
            
            //Remove the now empty folder
            try! myFileManager.removeItem(at: folder)
        }
    }
}
