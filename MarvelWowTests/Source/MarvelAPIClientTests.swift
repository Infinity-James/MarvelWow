//
//  MarvelAPIClientTests.swift
//  MarvelWow
//
//  Created by James Valaitis on 04/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import XCTest
@testable import MarvelWow

//	MARK: Marvel API Client Tests Class

/**
    `MarvelAPIClientTests`

    Tests the Marvel API Client's ability to communicate correctly with the Marvel servers.
 */
class MarvelAPIClientTests: XCTestCase {
    
    //	MARK: Properties
    
    private let marvelAPIClient = MarvelAPIClient()
    
    //	MARK: Tests
    
    /**
        Test the ability to fetch comics.
     */
    func testFetchingComics() {
        
        let comicFetchExpectation = expectationWithDescription("Comics should be fetched.")
        
        var query = MarvelAPIComicBookQuery()
        let limit = 10
        query.addParameter(.Limit(limit))
        do {
            try marvelAPIClient.fetchResourcesForQuery(query) { (comics: [MarvelComic]?, error: ErrorType?) in
                
                XCTAssertNotNil(comics)
                XCTAssertNil(error)
                
                XCTAssertEqual(limit, comics!.count)
                
                comicFetchExpectation.fulfill()
            }
        } catch {
            XCTFail("Resource fetched failed with error: \(error)")
        }
        
        //  10 seconds is a reasonable amount of time to wait even with a poor connection
        waitForExpectationsWithTimeout(10.0) { error in
            if let error = error {
                XCTFail("Resource fetched failed with error: \(error)")
            }
        }
    }
}