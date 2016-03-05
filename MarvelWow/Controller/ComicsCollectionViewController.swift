//
//  ComicsCollectionViewController.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

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
    
    //	MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  fetch the first set of comics
        fetchNextBatchOfComics()
    }
}

//	MARK: UICollectionViewDataSource Functions

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