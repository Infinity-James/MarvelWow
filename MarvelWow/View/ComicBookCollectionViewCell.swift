//
//  ComicBookCollectionViewCell.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import UIKit

//	MARK: Comics Book Collection View Cell

/**
    `ComicBookCollectionViewCell`

    A cell used to display a comic book within a collection view.
 */
class ComicBookCollectionViewCell: UICollectionViewCell {
 
    //	MARK: Properties - State
    
    /// The image of the front cover of the comics.
    var coverImage: UIImage? {
        get {
            return coverImageView.image
        }
        set {
            coverImageView.image = newValue
        }
    }
    
    //	MARK: Properties - Subviews
    
    /// The image view that displays the front cover of the comic.
    @IBOutlet private var coverImageView: UIImageView!
}