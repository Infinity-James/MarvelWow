//
//  ComicCoverFetchOperation.swift
//  MarvelWow
//
//  Created by James Valaitis on 06/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Comic Cover Fetch Operation

/**
    `ComicCoverFetchOperation`

    An operation that will fetch the cover image for a comic.
    If the image has been fetched before hand it can be accessed from a cache.
    We also check if the user has a custom image for comic saved in their Dropbox.
*/
class ComicCoverFetchOperation: NSOperation {
    
    //	MARK: Properties
    
    /// The comic we are going to fetch the cover image for.
    /// It has been made an implicitly unwrapped optional because it can only ever be nil if the initializer fails.
    /// It needs to be initialized to some value before returning from even a failed initializer.
    let comic: MarvelComic!
    /// An easy way to access the cover image URL.
    var comicCoverImageURL: NSURL { return comic.thumbnailURL! }
    /// The cover image if we have successfully fetched it.
    var coverImage: UIImage?
    
    //	MARK: Initialization
    
    /**
        Initializes the operation with the comic for which we want to fetch it's cover image.
    
        - Parameter comic:  The comic for which we want to fetch the cover image.
    
        - Returns:  An initialized comic cover fetch operation.
    */
    init?(comic: MarvelComic) {
        
        guard comic.thumbnailURL != nil else {
            print("We cannot create an operation to fetch a cover image for a comic that doesn't have a URL pointing to that image: \(comic)")
            self.comic = nil
            super.init()
            return nil
        }
        
        self.comic = comic
        
        super.init()
    }
    
    //	MARK: Operation
    
    override func main() {
        
        let data: NSData?
        
        //  first we check the cache for the cover image to save from fetching it
        
        //  if it's not in the cache we check if the user has an image in their Dropbox for this comic
        
        //  finally we fall back to fetching the image from it's location on the Marvel servers
        
        data = NSData(contentsOfURL: comicCoverImageURL)
        
        //  we should have some valid data by now, but if somehow we don't we fail out
        guard let imageData = data,
            image = UIImage(data: imageData) else {
                print("Could not get valid image data for comic: \(comic)")
                cancel()
                return
        }
        
        self.coverImage = image
    }
}