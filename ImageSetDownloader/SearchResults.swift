struct SearchResult: Decodable {
    let photos: Photos
}

struct Photos: Decodable {
    let photo: [Photo]
}

struct Photo: Decodable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}
