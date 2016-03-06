//
//  ComicsCollectionViewController.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import MobileCoreServices
import SwiftyDropbox
import UIKit

//	MARK: Comics Collection View Controller

/**
    `ComicsCollectionViewController`

    A controller of a collection view used to display comic books, ordered by default from newest to oldest.
 */
class ComicsCollectionViewController: UICollectionViewController {
    
    //	MARK: Constants
    
    /// The number of comics we will fetch each time.
    private let comicBatchSize = 60
    
    //	MARK: Properties - State
    
    /// The comics to display in the collection view.
    private var comics = [MarvelComic]()
    /// The client we will use to fetch the comics.
    private let marvelAPIClient = MarvelAPIClient()
    /// The comic whose cover we are currently changing (if one exists).
    private var comicForCoverChange: MarvelComic?
    /// A queue on which we will execute cover image fetch operations.
    private let comicCoverOperationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.name = "Cover Image Fetch Operation Queue"
        return queue
    }()
    /// Track whether we are already fetching comics.
    private var fetchInProgress = false
    
    //	MARK: Comic Fetching
    
    /**
        Fetches the next batch of comics depending on how many we already have.
     */
    private func fetchNextBatchOfComics() {
        guard !fetchInProgress else { return }
        
        fetchInProgress = true
        
        var query = MarvelAPIComicBookQuery()
        query.addParameter(.Limit(comicBatchSize))
        query.addParameter(.Offset(comics.count))
        do {
            try marvelAPIClient.fetchResourcesForQuery(query) { (comics: [MarvelComic]?, error: ErrorType?) in
                
                self.fetchInProgress = false
                
                //  if there were any comics fetched we add them to the comics that we already have and display them
                if let comics = comics {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.comics.appendContentsOf(comics)
                        self.collectionView!.reloadData()
                    }
                    //  if an error occured during the fetch we'll log it
                } else if let error = error {
                    print("Error occured whilst trying to fetch comics: \(error)")
                }
            }
        } catch {
            print("Error occured whilst trying to fetch comics: \(error)")
            fetchInProgress = false
        }
    }
    
    //	MARK: Comic Cover Changing
    
    private func allowUserToSelectComicCover() {
        let actionSheet = UIAlertController(title: "Where's the photo?", message: nil, preferredStyle: .ActionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a New Photo", style: .Default) { _ in
            NSOperationQueue.mainQueue().addOperationWithBlock { self.displayPhotoPickerWithSourceType(.Camera) }
        }
        let pickPhotoAction = UIAlertAction(title: "In My Photos Library", style: .Default) { _ in
            NSOperationQueue.mainQueue().addOperationWithBlock { self.displayPhotoPickerWithSourceType(.PhotoLibrary) }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(pickPhotoAction)
        actionSheet.addAction(cancelAction)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func displayPhotoPickerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        
        //  we can only do the possible, the impossible is but a dream
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func saveComicCoverToDropbox(coverImage: UIImage, forComic comic: MarvelComic) {
        
        //  if the user isn't logged in to dropbox we need them to log in first
        guard let client = Dropbox.authorizedClient else {
            let alert = UIAlertController(title: "Save Your Cover!", message: "If you log in to Dropbox you can save your new cover so it's always there.", preferredStyle: .Alert)
            let logInAction = UIAlertAction(title: "Log In", style: .Default) { [unowned self] _ in Dropbox.authorizeFromController(self) }
            let cancelAction = UIAlertAction(title: "Nope", style: .Cancel, handler: nil)
            alert.addAction(logInAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        //  now that the user is logged in to Dropbox we can upload their photo
        let imageData = UIImageJPEGRepresentation(coverImage, 0.9)
        //  create the file name from the ID of the comic (allowing us to use it in the future for this comic)
        let fileName = "/" + String(comic.ID) + ".jpg"
        client.files.upload(path: fileName, body: imageData!).response { response, error in
            //  cache the image now that it
        }
    }
    
    //	MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  fetch the first set of comics
        fetchNextBatchOfComics()
    }
}

//	MARK: UICollectionViewDataSource

extension ComicsCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //  get the cell
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(ComicBookCollectionViewCell), forIndexPath: indexPath) as? ComicBookCollectionViewCell else {
            fatalError("Collection view is not configured properly. Expected cell with the reuse identifier: \(String(ComicBookCollectionViewCell))")
        }
        
        //  set the cell tag to it's item so that we know if it's worth setting the image on it by the time we have it
        cell.tag = indexPath.item
        
        //  set the image for the comic cell
        let comic = comics[indexPath.item]
        if let coverFetchOperation = ComicCoverFetchOperation(comic: comic) {
            coverFetchOperation.completionBlock = {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //  only update the cell if it is still displayed (by the time we get the image it might be irrelevant)
                    if cell.tag == indexPath.item {
                        cell.coverImage = coverFetchOperation.coverImage
                    }
                }
            }
            comicCoverOperationQueue.addOperation(coverFetchOperation)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }
}

//	MARK: UICollectionViewDelegate

extension ComicsCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        //  the collection view may update between the user selecting the comic and choosing a cover
        //  therefore we store which comic we are changing, rather than the place in the collection view (index path)
        comicForCoverChange = comics[indexPath.item]
        
        //  when the user selects a comic we will give them the option to change the cover image for that comic
        let alert = UIAlertController(title: "Add Your Own Cover!", message: "Do you want to change the cover of this comic to something even more awesome?", preferredStyle: .Alert)
        let hellYeahAction = UIAlertAction(title: "Hell Yeah", style: .Default) { [unowned self] _ in self.allowUserToSelectComicCover() }
        let boringAction = UIAlertAction(title: "Nah", style: .Cancel, handler: nil)
        alert.addAction(hellYeahAction)
        alert.addAction(boringAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}

//	MARK: UIScrollViewDelegate

extension ComicsCollectionViewController {
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let heightOfCollection = scrollView.contentSize.height
        let positionInCollection = scrollView.bounds.maxY
        let distanceFromBottom = heightOfCollection - positionInCollection
        
        //  if the user is a few comics from the bottom we need to load more
        let unacceptableDistanceFromBottom = (collectionView!.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.height * 2
        if distanceFromBottom <= unacceptableDistanceFromBottom {
            fetchNextBatchOfComics()
        }
    }
}

//	MARK: UIImagePickerControllerDelegate

extension ComicsCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        guard let comicForCoverChange = comicForCoverChange else {
            print("The user chose a new cover image, but apparently there is no comic for which we need to use this image.")
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        //  cache the new image
        do {
            try ComicCoverImageCache.cacheCoverImage(image, forComic: comicForCoverChange)
        } catch {
            print("Error occurred when trying to cache the image \(image) for the comic: \(comicForCoverChange)")
        }
        
        saveComicCoverToDropbox(image, forComic: comicForCoverChange)
        
        //  reload the comic cell with the new cover
        if let index = comics.indexOf({ $0.ID == comicForCoverChange.ID }) {
            let itemIndex = comics.startIndex.distanceTo(index)
            collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: itemIndex, inSection: 0)])
        }
        
        self.comicForCoverChange = nil
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        comicForCoverChange = nil
        dismissViewControllerAnimated(true, completion: nil)
    }
}