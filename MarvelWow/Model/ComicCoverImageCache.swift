//
//  File.swift
//  MarvelWow
//
//  Created by James Valaitis on 06/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Comic Cover Image Cache

/**
    `ComicCoverImageCache`

    A layer on top of the data cache specifically for caching comic cover images.
 */
struct ComicCoverImageCache {
    
    //	MARK: Comic Cover Image Cache Error
    
    /**
        `ComicCoverImageCacheError`
    
        An error that can be return by the `ComicCoverImageCache`.
     */
    enum ComicCoverImageCacheError: ErrorType {
        //  The provided image could not be transformed into data.
        case InvalidImage(UIImage)
    }
    
    //	MARK: Caching
    
    /**
        Caches an image associated with the given comic.
    
        - Parameter coverImage: The cover image to be cached.
        - Parameter comic:      The comic for which we are caching the image.
     */
    static func cacheCoverImage(coverImage: UIImage, forComic comic: MarvelComic) throws {
        guard let imageData = UIImageJPEGRepresentation(coverImage, 1.0) else {
            throw ComicCoverImageCacheError.InvalidImage(coverImage)
        }
        
        cacheCoverImageData(imageData, forComic: comic)
    }
    
    /**
     Caches an image associated with the given comic.
     
     - Parameter coverImage: The cover image to be cached.
     - Parameter comic:      The comic for which we are caching the image.
     */
    static func cacheCoverImageData(coverImageData: NSData, forComic comic: MarvelComic) {
        
        let key = String(comic.ID)
        DataCache.storeData(coverImageData, forKey: key)
    }
    
    /**
        Retrieves a cover image for a comic from the cache if it exists there.
     
        - Parameter comic:  The comic for which we want the cover image.
        
        - Returns:  The cover image for the comic if it exists in the cache, `nil` if it doesn't.
     */
    static func coverImageForComic(comic: MarvelComic) -> UIImage? {
        
        let key = String(comic.ID)
        guard let coverImageData = DataCache.dataForKey(key) else {
            //  the image does not exist in the cache
            return nil
        }
        
        let coverImage = UIImage(data: coverImageData)
        return coverImage
    }
}