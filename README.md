# ImageSetDownloader

Easily create image classifier ML models without writing any code! This script allows you to download sets of classified images from [Flickr's API](https://www.flickr.com/services/api/), then split/combine to/from training and test folders. The folder structure matches that required by [Apple's Create ML](https://developer.apple.com/documentation/createml/creating_an_image_classifier_model). You can drag the resulting folders into CreateML and train your model (or use another framework).

## Examples
Download 10 pictures of cats
```
./ImageSetDownloader --download --tag "cats" --apiKey yourFlickrApiKey --max 10
```

Split your images into training and testing folders
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

### --max (or -m)
Maximum number of images to download. If not specified, defaults to 500.


## Notes
To get an API key from Flickr, [sign up here](https://www.flickr.com/services/apps/create/).

Some of the results returned by Flickr are not always the most accurate, depending on the search query. You can choose to manually filter the pictures for additional accuracy of the training set. 
