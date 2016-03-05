//
//  MarvelAPIQueryTests.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import XCTest
@testable import MarvelWow

//	MARK: Marvel API Query Tests Class

/**
    `MarvelAPIQueryTests`

    A class that will test the various elements of the Marvel API Query structure.
 */
class MarvelAPIQueryTests: XCTestCase {
    
    /**
        Test the various general query parameters.
     */
    func testGeneralQueryParameters() {
        let orderValue = "focDate"
        let orderByParameter = MarvelAPIGeneralQueryParameter.OrderBy(orderValue)
        XCTAssertEqual(orderByParameter.asParameterString(), "orderBy=" + orderValue)
        
        let limit = 60
        let limitParameter = MarvelAPIGeneralQueryParameter.Limit(limit)
        XCTAssertEqual(limitParameter.asParameterString(), "limit=" + String(limit))
        
        let offset = 50
        let offsetParameter = MarvelAPIGeneralQueryParameter.Offset(offset)
        XCTAssertEqual(offsetParameter.asParameterString(), "offset=" + String(offset))
    }
    
    /**
        Test the various comic query parameters.
     */
    func testComicQueryParameters() {
        
        //  the Marvel API expects the dates in this format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let startDate = NSDate(timeIntervalSince1970: 0.0)
        let endDate = NSDate()
        let dateRangeParameter = MarvelAPIComicQueryParameter.DateRange(startDate, endDate)
        XCTAssertEqual(dateRangeParameter.asParameterString(), "dateRange=" + dateFormatter.stringFromDate(startDate) + "," + dateFormatter.stringFromDate(endDate))
        
        //  the boolean should be displayed as 'true' or 'false'
        let variantsParameterA = MarvelAPIComicQueryParameter.ExcludeVariants(true)
        let variantsParameterB = MarvelAPIComicQueryParameter.ExcludeVariants(false)
        XCTAssertEqual(variantsParameterA.asParameterString(), "noVariants=true")
        XCTAssertEqual(variantsParameterB.asParameterString(), "noVariants=false")
        
        //  test the format and format types are sent correctly
        let format = MarvelAPIComicFormat.DigitalComic
        let formatParameter = MarvelAPIComicQueryParameter.Format(format)
        XCTAssertEqual(formatParameter.asParameterString(), "format=" + format.rawValue)
        
        let formatType = MarvelAPIComicFormatType.Collection
        let formatTypeParameter = MarvelAPIComicQueryParameter.FormatType(formatType)
        XCTAssertEqual(formatTypeParameter.asParameterString(), "formatType=" + formatType.rawValue)
    }
    
    /**
        Tests that a comic query will generate a correct query path component given parameters.
     */
    func testComicBookQueryPathComponent() {
        //  create the query
        var comicBookQuery = MarvelAPIComicBookQuery()
        
        //  test the default path component for a comic book query
        let expectedDefaultPathComponent = "&format=comic&formatType=comic"
        XCTAssertEqual(expectedDefaultPathComponent, comicBookQuery.fullQueryPathComponent)
        
        //  add parameters to the query and test the path component contains the parameters
        let limit = 30
        let limitParameter = MarvelAPIGeneralQueryParameter.Limit(limit)
        comicBookQuery.addParameter(limitParameter)
        
        let excludeVariantsParameter = MarvelAPIComicQueryParameter.ExcludeVariants(true)
        comicBookQuery.addParameter(excludeVariantsParameter)
        
        let expectedPathComponent = expectedDefaultPathComponent + "&limit=" + String(limit) + "&noVariants=true"
        XCTAssertEqual(expectedPathComponent, comicBookQuery.fullQueryPathComponent)
    }
}