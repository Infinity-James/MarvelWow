//
//  ComicsCollectionViewController.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

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
    
    //	MARK: Comic Fetching
    
    /**
        Fetches the next batch of comics depending on how many we already have.
     */
    private func fetchNextBatchOfComics() {
        var query = MarvelAPIComicBookQuery()
        query.addParameter(.Limit(comicBatchSize))
        query.addParameter(.Offset(comics.count))
        do {
            try marvelAPIClient.fetchResourcesForQuery(query) { (comics: [MarvelComic]?, error: ErrorType?) in
                
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
        }
    }
    
    //	MARK: Comic Cover Changing
    
    private func changeCoverForComicAtIndexPath(comicIndexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Where's the photo?", message: nil, preferredStyle: .ActionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a New Photo", style: .Default) { _ in
            
        }
        let pickPhotoAction = UIAlertAction(title: "In My Photos Library", style: .Cancel) { _ in
        }
    }
    
    private func displayPhotoPickerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        
        //  we can only do the possible, the impossible is but a dream
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func saveComicCoverToDropbox() {
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
        
        //  when the user selects a comic we will give them the option to change the cover image for that comic
        let alert = UIAlertController(title: "Add Your Own Cover!", message: "Do you want to change the cover of this comic to something even more awesome?", preferredStyle: .Alert)
        let hellYeahAction = UIAlertAction(title: "Hell Yeah", style: .Default) { [unowned self] _ in Dropbox.authorizeFromController(self) }
        let boringAction = UIAlertAction(title: "Nah", style: .Cancel, handler: nil)
        alert.addAction(hellYeahAction)
        alert.addAction(boringAction)
    }
}

//	MARK: UIImagePickerControllerDelegate

extension ComicsCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}