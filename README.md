# ImageSetDownloader

Easily create image classifier ML models using data from Flickr's API! This script allows you to download sets of classified images from [Flickr's API](https://www.flickr.com/services/api/), then split/combine to/from training and test folders. The folder structure matches that required by [Apple's Create ML](https://developer.apple.com/documentation/createml). 

## Examples
Download 10 pictures of cats
```
./ImageSetDownloader --download --tag "cats" --apiKey yourFlickrApiKey --max 10
```

Split your images into training and testing folder
```
./ImageSetDownloader --split
```

Combine your testing and training sets back to a single folder
```
./ImageSetDownloader --combine
```

## Usage
### --path (or -p)
Specify a path to use. If not specified, defaults to the current directory.

### --split (or -s)
Split the folders in the directory to training and testing sets

### --combine (or -c)
Combine files in training/testing folders under the directory to one folder.

### --download (or -d)
Downloads images from Flickr's API.

### --apiKey (or -a)
A Flickr API key. This is required for the download command.

### --tag (or -t)
What to search for. Required for the download command.

## --max (or -m)
Maximum number of images to download. If not specified, defaults to 500.
