import Foundation

class MyRequestController {
    let flickrBaseURL = "https://api.flickr.com/services/rest/"
    let session: URLSession
    init() {
        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    }
    
    func downloadImage(photo: Photo, directory: URL) {
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
            } catch (let writeError) {
                print(writeError.localizedDescription)
            }
            
        }).resume()
    }
    
    func searchImage(of tag: String, withMaximum recordNum: Int, completion: @escaping ([Photo])->()) {
        let perPage = min(500, recordNum)
        
        let URLParams = [
            "api_key": "",
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
    
    func downloadImages(of tag: String, to directory: String, withMaximum imageCount: Int) {
        let localUrl = URL(fileURLWithPath: directory).appendingPathComponent(tag)
        
        do {
            try FileManager.default.createDirectory(at: localUrl, withIntermediateDirectories: true)
        } catch (let error) {
            print(error.localizedDescription)
            return
        }
        
        searchImage(of: tag, withMaximum: imageCount, completion: {(photos: [Photo]) -> Void in
            for photo in photos {
                self.downloadImage(photo: photo, directory: localUrl)
            }
        })
    }
}

//MyRequestController().downloadImages(of: "TaylorSwift", to: "/Users/zeke/Desktop/ImageSetDownloader/ImageSetDownloader/test", withMaximum: 1000)


SplitTraining().split(directory: "/Users/zeke/Desktop/ImageSetDownloader/ImageSetDownloader/test")
//SplitTraining().combine(directory: "/Users/zeke/Desktop/ImageSetDownloader/ImageSetDownloader/test")
sleep(200)
