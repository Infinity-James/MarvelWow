//
//  ComicCoverFetchOperation.swift
//  MarvelWow
//
//  Created by James Valaitis on 06/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import SwiftyDropbox
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
    
    //	MARK: Image Location Checking
    
    /**
        Fetches the cover image from the Dropbox folder for this app.
    
        - Parameter client:     The Dropbox client to use to fetch the image from the server if it exists.
        - Parameter completion: A block called once we have finished trying to fetch the image (successfully or not).
            - coverImage:   The image if we managed to fetch it, `nil` if we failed.
     */
    private func fetchFromDropbox(withClient client: DropboxClient, completion: (coverImage: UIImage?) -> ()) {
        let expectedFileName = String(comic.ID) + ".jpg"
        
        //  given a URL and a response return a URL to save the downloaded Dropbox image to
        let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            //  generate a unique name for this file in case we've seen it before
            let UUID = NSUUID().UUIDString
            let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
            return directoryURL.URLByAppendingPathComponent(pathComponent)
        }
        
        //  if it exists in their Dropbox we download it
        client.files.listFolder(path: "").response { response, error in
            if let files = response where files.entries.contains( { $0.name == expectedFileName } ) {
                client.files.download(path: expectedFileName, destination: destination).response { response, error in
                    if let (_, URL) = response,
                        imageData = NSData(contentsOfURL: URL),
                        image = UIImage(data: imageData) {
                            completion(coverImage: image)
                    } else {
                        completion(coverImage: nil)
                    }
                }
            } else {
                completion(coverImage: nil)
            }
        }
    }
    
    /**
        Fetches the cover image from Marvel's servers.
     */
    private func fetchFromServer() {
        //  finally we fall back to fetching the image from it's location on the Marvel servers
        guard let imageData = NSData(contentsOfURL: self.comicCoverImageURL),
            image = UIImage(data: imageData) else {
                print("Completely failed to find an image for the comic: \(self.comic)")
                self.cancel()
                return
        }
        
        //  once we've fetched the image from the server we store it and cache it
        self.coverImage = image
        ComicCoverImageCache.cacheCoverImageData(imageData, forComic: self.comic)
    }
    
    /**
        Retrieves the cover image from teh cache if it is in there.
        
        - Returns:  `true` if it was found in the cache and retrieved, `false` otherwise.
     */
    private func retrieveFromCache() -> Bool {
        //  first we check the cache for the cover image to save from fetching it
        guard let cachedImage = ComicCoverImageCache.coverImageForComic(comic) else {
            return false
        }
        
        coverImage = cachedImage
        return true
    }
    
    //	MARK: Operation
    
    override func main() {
        
        //  if it's in the cache we needn't try anything else
        if retrieveFromCache() {
            return
        }
        
        //  if the user is logged in to Dropbox…
        if let client = Dropbox.authorizedClient {
            fetchFromDropbox(withClient: client) { coverImage in
                //  if the cover image existed in Dropbox we use it
                if let coverImage = coverImage {
                    //  store it and cache it
                    self.coverImage = coverImage
                    do {
                        try ComicCoverImageCache.cacheCoverImage(coverImage, forComic: self.comic)
                    } catch {
                        print("Failed to cache the image: \(coverImage)")
                    }
                    return
                    //  otherwise, if it wasn't in Dropbox we fetch it from the server
                } else {
                    self.fetchFromServer()
                }
            }
            //  if the user is not logged in to Dropbox we know to just fetch it from the server
        } else {
            fetchFromServer()
        }
    }
}