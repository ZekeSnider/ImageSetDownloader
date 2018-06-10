import Foundation

class MyRequestController {
    let session: URLSession
    init() {
        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    }
    
    func downloadImage(photo: Photo, directory: URL) {
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
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
    
    func searchImage(of tag: String, recordNum: Int, completion: @escaping ([Photo])->()) {
        guard recordNum <= 500 else {return}
        guard var URL = URL(string: "https://api.flickr.com/services/rest/") else {return}
        let URLParams = [
            "api_key": "",
            "tags": tag,
            "method": "flickr.photos.search",
            "format": "json",
            "nojsoncallback": "1",
            "media": "photos",
            "per_page": String(recordNum),
            "sort": "relevance"
        ]
        
        URL = URL.appendingQueryParameters(URLParams)
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
                print("Error: Couldn't decode data into Blog \(error.localizedDescription)")
                return
            }
            print("got \(photos.photos.photo.count) photos")
            completion(photos.photos.photo)
        }).resume()
    }
    
    
    func downloadImages(of tag: String, to directory: String, images: Int) {
        //"/Users/zeke/Desktop/ImageSetDownloader/ImageSetDownloader/test"
        let localUrl = URL(fileURLWithPath: directory).appendingPathComponent(tag)
        
        do {
            try FileManager.default.createDirectory(at: localUrl, withIntermediateDirectories: true)
        } catch (let error) {
            print(error.localizedDescription)
        }
        
        searchImage(of: tag, recordNum: images, completion: {(photos: [Photo]) -> Void in
            for photo in photos {
                self.downloadImage(photo: photo, directory: localUrl)
            }
        })
    }
}

//MyRequestController().downloadImages(of: "TaylorSwift", to: "/Users/zeke/Desktop/ImageSetDownloader/ImageSetDownloader/test", images: 30)


SplitTraining().splitDirectory()
sleep(200)
