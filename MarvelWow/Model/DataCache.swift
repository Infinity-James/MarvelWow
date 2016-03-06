//
//  DataCache.swift
//  MarvelWow
//
//  Created by James Valaitis on 06/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Data Cache

/**
    DataCache

    An object capable of caching data.
*/
struct DataCache {
    
    ///	50Mb is maximum size of cache.
    private static let maxCacheSize = 52428800
    ///	30Mb is the size of the cache at which we stop trimming.
    private static let trimCacheSize = 31457280
    
    /// A convenient way to get the URL at which the caches exist.
    private static let cachesURL: NSURL = {
        let cachesDirectories = NSFileManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return cachesDirectories.last!
    }()
    
    //	MARK: Cache Management
    
    /**
        Trims the cache if necessary.
    
        - Returns:  Whether or not a trim was performed on the cache.
    */
    static private func trimCache() -> Bool {
        
        //  get all of the files in the cache
        let URLsInCache = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(cachesURL, includingPropertiesForKeys: [], options: .SkipsHiddenFiles)
        //  calculate the size of the cache as it currently exists
        var cacheSize = 0
        URLsInCache.forEach { cacheSize += $0.fileSize ?? 0 }
        
        print("Cache Size: \(cacheSize / 1000)Mb")
        
        //  if the cache is still small enough we can exit early
        guard cacheSize < maxCacheSize else { return false }
        
        //  sort the files in order of newest to oldest
        let sortedURLs = URLsInCache.sort { urlA, urlB in
            return urlA.creationDate!.compare(urlB.creationDate!) == .OrderedDescending
        }
        
        //  we remove old cached files until we are below the cache size
        for URL in sortedURLs where cacheSize > trimCacheSize {
            
            if URL.fileType == NSFileTypeRegular {
                cacheSize -= URL.fileSize!
                try! NSFileManager.defaultManager().removeItemAtURL(URL)
            }
        }
        
        return true
    }
    
    //	MARK: Data Management
    
    /**
        Returns the data for a given key.
    
        - Parameter key:    The key which maps to the data.
    
        - Returns:  The data associated with the key if it exists.
     */
    static func dataForKey(key: String) -> NSData? {
        let URL = URLForDataWithKey(key)
        let cachedData = NSData(contentsOfURL: URL)
        return cachedData
    }
    
    /**
        Stores data in the cache.
     
        - Parameter data:   The data to store in teh cache.
        - Parameter key:    The key under which we store the data.
     */
    static func storeData(data: NSData, forKey key: String) {
        
        let URL = URLForDataWithKey(key)
        
        //  write data to file system on this thread because we want this URL to be valid before we trim the cache
        data.writeToURL(URL, atomically: false)
        
        //  make sure cache is not too big
        let dispatchQueue = dispatch_queue_create("trimCache", nil);
        
        dispatch_async(dispatchQueue) {
            trimCache()
        }
    }
    
    /**
        Created a URL to store data for a given key.
     
        - Parameter key:    The key for which we generate a URL.
     
        - Returns:  A URL to store the data associated with the provided key.
     */
    private static func URLForDataWithKey(key: String) -> NSURL {
        return cachesURL.URLByAppendingPathComponent(key)
    }
}

//	MARK: NSURL - Convenience Attributes

extension NSURL {
    
    /// A convenient way to get the file attributes for the item at this URL.
    var attributes: [String: AnyObject]? {
        let attributes: [String: AnyObject]?
        do {
            attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path!)
        } catch {
            print("Error trying to read attributes for URL.\nURL: \(self.absoluteString)\nError: \(error)")
            attributes = nil
        }
        
        return attributes
    }

    /// A convenient way to get the size of the item at this URL.
    var fileSize: Int? {
        var fileSize: AnyObject?
        do {
            try getResourceValue(&fileSize, forKey: NSFileSize)
        } catch {
            print("Error whilst trying to get file size for URL \(self): \(error)")
        }
        
        if fileSize == nil {
            fileSize = attributes?[NSFileSize]
        }
        
        return fileSize as? Int
    }
    
    /// A convenient way to get the creation date of the item at this URL.
    var creationDate: NSDate? {
        var creationDate: AnyObject?
        do {
            try getResourceValue(&creationDate, forKey: NSURLCreationDateKey)
        } catch {
            print("Error whilst trying to get creation date for URL \(self): \(error)")
        }
        
        if creationDate == nil {
            creationDate = attributes?[NSURLCreationDateKey]
        }
        
        return creationDate as? NSDate
    }
    
    /// A convenient way to get the file type of the item at this URL.
    var fileType: String? {
        var fileType: AnyObject?
        do {
            try getResourceValue(&fileType, forKey: NSFileType)
        } catch {
            print("Error whilst trying to get file type for URL \(self): \(error)")
        }
        
        if fileType == nil {
            fileType = attributes?[NSFileType]
        }
        
        return fileType as? String
    }
}