import Foundation
import TSCUtility

let parser = ArgumentParser(commandName: "imagesetdownloader", usage: "--download --tag cats --apiKey myFlickrApiKey --maxRecords 10", overview: "Downloads flickr data sets, splits to training data, or combines to one folder of images.")

let tag = parser.add(option: "--tag", shortName: "-t", kind: String.self, usage: "A search tag")
let apiKey = parser.add(option: "--apiKey", shortName: "-a", kind: String.self, usage: "Flickr API Key")
let path = parser.add(option: "--path", shortName: "-p", kind: PathArgument.self, usage: "Path to download to")
let maximumRecords = parser.add(option: "--maxRecords", shortName: "-m", kind: Int.self, usage: "Maximum images to download")

let combine = parser.add(option: "--combine",
    shortName: "-c",
    kind: Bool.self,
    usage: "Combines files into one folder",
    completion: ShellCompletion.none)
let split = parser.add(option: "--split",
    shortName: "-s",
    kind: Bool.self,
    usage: "Splits into training and testing sets",
    completion: ShellCompletion.none)
let download = parser.add(option: "--download",
    shortName: "-d",
    kind: Bool.self,
    usage: "Downloads image set from flickr",
    completion: ShellCompletion.none)

enum ParameterError: Error {
    case tagRequired
    case apiKeyRequired
    case commandRequired
}

extension ParameterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .tagRequired:
            return "A tag is required to search for images"
        case .apiKeyRequired:
            return "An api key is required to search for images"
        case .commandRequired:
            return "You must specify at least one of split, combine, or download."
        }
    }
}

do {
    let args = Array(CommandLine.arguments.dropFirst())
    let result = try parser.parse(args)
    
    if ([result.get(combine), result.get(split), result.get(download)]
        .filter { $0 == true }
        .count != 1) {
        throw ParameterError.commandRequired
    }
    
    let pathArg = result.get(path)?.path.asURL ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    if (result.get(download) == true) {
        guard let tagString = result.get(tag) else {
            throw ParameterError.tagRequired
        }
        guard let apiKeyString = result.get(apiKey) else {
            throw ParameterError.apiKeyRequired
        }
        let maximumRecordsInt = result.get(maximumRecords) ?? 500
        
        let sem = DispatchSemaphore(value: 0)
        FlickrController().downloadImages(of: tagString, to: pathArg, withMaximum: maximumRecordsInt, using: apiKeyString, completion: {() -> Void in
            print("Completed download!")
            sem.signal()
        })
        sem.wait()
    } else if (result.get(split) == true) {
        SplitTraining().split(parentFolderDirectory: pathArg)
    } else if (result.get(combine) == true) {
        SplitTraining().combine(parentFolderDirectory: pathArg)
    }
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}
