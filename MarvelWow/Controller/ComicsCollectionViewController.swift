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
    
    
    
    //	MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  fetch the first set of comics
    }
}