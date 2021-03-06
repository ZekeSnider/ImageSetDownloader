//
//  FlickrController.swift
//  ImageSetDownloader
//
//  Created by Zeke Snider on 5/2/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation

class FlickrController {
    let flickrBaseURL = "https://api.flickr.com/services/rest/"
    let session: URLSession
    init() {
        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    }
    
    func downloadImage(photo: Photo, directory: URL, completion: @escaping ()->()) {
        //format is: https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        let imageURL = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        guard let downloadURL = URL(string: imageURL) else { return }
        let fileURL = directory.appendingPathComponent("\(photo.id).jpg")
        
        guard !FileManager.default.fileExists(atPath: fileURL.absoluteString) else {
            return
        }
        
        var request = URLRequest(url: downloadURL)
        request.httpMethod = "GET"
        
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                try data?.write(to: fileURL)
                print("Downloaded \(photo.id).jpg")
                completion()
            } catch (let writeError) {
                print(writeError.localizedDescription)
            }
        }).resume()
    }
    
    func searchImage(of tag: String, withMaximum recordNum: Int, using ApiKey: String, completion: @escaping ([Photo])->()) {
        let perPage = min(500, recordNum)
        
        let URLParams = [
            "api_key": ApiKey,
            "tags": tag,
            "method": "flickr.photos.search",
            "format": "json",
            "nojsoncallback": "1",
            "media": "photos",
            "per_page": String(perPage),
            "sort": "relevance",
            "page": "1"
        ]
        
        return makeSearchRequestsUntilDone(for: URLParams, withMaximum: recordNum, addingTo: [Photo](), completion: completion)
    }
    
    private func makeSearchRequestsUntilDone(for params: [String: String], withMaximum recordNum: Int, addingTo photos: [Photo], completion: @escaping ([Photo])->()) {
        makeSearchRequest(with: params, completion: {(newPhotos: [Photo]) -> Void in
            let allPhotos = newPhotos + photos
            if (allPhotos.count < recordNum) {
                var newParams = params
                newParams["page"] = String(Int(newParams["page"]!)! + 1)
                return self.makeSearchRequestsUntilDone(for: newParams, withMaximum: recordNum, addingTo: allPhotos, completion: completion)
            } else {
                return completion(allPhotos)
            }
        })
    }
    
    private func makeSearchRequest(with parameters: [String: String], completion: @escaping ([Photo])->()) {
        guard var URL = URL(string: flickrBaseURL) else {return}
        
        URL = URL.appendingQueryParameters(parameters)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard error == nil else {
                print("URL Session Task Failed: %@", error!.localizedDescription);
                return
            }
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                return
            }
            guard let data = data else {
                return
            }
            
            let photos: SearchResult
            do {
                photos = try JSONDecoder().decode(SearchResult.self, from: data)
            } catch (let error) {
                print("Error: Couldn't decode data into search result. \(error.localizedDescription)")
                return
            }
            
            completion(photos.photos.photo)
        }).resume()
    }
    
    func downloadImages(of tag: String, to directory: String, withMaximum imageCount: Int, using apiKey: String, completion: @escaping ()->()) {
        downloadImages(of: tag, to: URL(fileURLWithPath: directory), withMaximum: imageCount, using: apiKey, completion: completion)
    }
    
    func downloadImages(of tag: String, to directory: URL, withMaximum imageCount: Int, using apiKey: String, completion: @escaping ()->()) {
        let localUrl = directory.appendingPathComponent(tag)
        
        do {
            try FileManager.default.createDirectory(at: localUrl, withIntermediateDirectories: true)
        } catch (let error) {
            print(error.localizedDescription)
            return
        }
        
        print("Searching for \(imageCount) pictures related to \(tag).")
        searchImage(of: tag, withMaximum: imageCount, using: apiKey, completion: {(photos: [Photo]) -> Void in
            print("Search complete! Starting downloads")
            let myGroup = DispatchGroup()
            
            for photo in photos {
                myGroup.enter()
                self.downloadImage(photo: photo, directory: localUrl, completion: {() -> Void in
                    myGroup.leave()
                })
            }
            
            myGroup.notify(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)) {
               completion()
            }
        })
    }
}
