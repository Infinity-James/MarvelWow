//
//  MarvelAPIQuery.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Marvel API Query Parameter Protocol

/**
    `MarvelAPIQueryParameter`

    Defines a type which can serve as a parameter for a query to the Marvel API.
*/
protocol MarvelAPIQueryParameter {
    
    /**
         Returns the parameter as a string.
         
         - Returns:  The parameter as a string to be used in a query.
     */
    func asParameterString() -> String
}

//	MARK: Marvel API General Query Parameter Enum

/**
    `MarvelAPIGeneralQueryParameter`

    Defines the parameters available when making a query to the Marvel API.
    Making this an enum ensures safety for making a query with valid parameters.
*/
enum MarvelAPIGeneralQueryParameter: MarvelAPIQueryParameter {
    
    //	MARK: Cases
    
    /// The manner in which to order the resources.
    case OrderBy(String)
    /// The number of desired resources.
    case Limit(Int)
    /// The number of resources to skip in the set of results.
    case Offset(Int)
    
    //	MARK: MarvelAPIQueryParameter
    
    func asParameterString() -> String {
        switch self {
        case .Limit(let limit):
            return "limit=" + String(limit)
        case .Offset(let offset):
            return "offset=" + String(offset)
        case .OrderBy(let order):
            return "orderBy=" + order
        }
    }
}

/**
    `MarvelAPIComicQueryParameter`
 
    Defines the parameters available when making a comic query to the Marvel API.
    Making this an enum ensures safety for making a query with valid parameters.
 */
enum MarvelAPIComicQueryParameter: MarvelAPIQueryParameter {
    
    //	MARK: Cases
    
    /// The range of dates between which the comics that we want exist.
    case DateRange(NSDate, NSDate)
    /// Whether or not to exclude variants.
    case ExcludeVariants(Bool)
    /// The comic format.
    case Format(MarvelAPIComicFormat)
    /// The comic format type.
    case FormatType(MarvelAPIComicFormatType)
    
    //	MARK: Properties
    
    private var dateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        return dateFormatter
    }
    
    //	MARK: MarvelAPIQueryParameter
    
    func asParameterString() -> String {
        switch (self) {
        case .DateRange(let startDate, let endDate):
            //  the date formatter has to be a computed property so we grab a handle to it to avoid creating a new one each time
            let formatter = dateFormatter
            //  create the strings from the data for the parameter
            let startDateString = formatter.stringFromDate(startDate)
            let endDateString = formatter.stringFromDate(endDate)
            return "dateRange=" + startDateString + "," + endDateString
        case .ExcludeVariants(let exclude):
            return "noVariants=" + (exclude ? "true" : "false")
        case .Format(let format):
            return "format=" + format.rawValue
        case .FormatType(let formatType):
            return "formatType=" + formatType.rawValue
        }
    }
}

//	MARK: Comic Specific Keys

//	MARK: Marvel API Query Protocol

/**
    `MarvelAPIQuery`

    A protocol conformed to by objects to be executed as a query to the Marvel API.
*/
protocol MarvelAPIQuery {
    
    //	MARK: Properties
    
    /// The endpoint path component for this query.
    var endpointAPIPath: String { get }
    /// The query as a path component to be appended to the API endpoint.
    var fullQueryPathComponent: String { get }
    /// The parameters for the query.
    var parameters: [MarvelAPIQueryParameter] { get }
}

extension MarvelAPIQuery {
    
    //	MARK: Computed Properties
    
    
    var fullQueryPathComponent: String {
        let parametersStrings = parameters.map { $0.asParameterString() }
        let pathComponent = parametersStrings.reduce("") { $0.0 + "&" + $0.1 }
        return pathComponent
    }
}

//	MARK: Marvel API Comic Format Enum

/**
    `MarvelAPIComicFormat`

    Defines the type of comic formats which are available in a query.
    Each case maps to it's representation as a URL parameter.
*/
enum MarvelAPIComicFormat: String {
    /// The standard comic book format.
    case Comic = "comic"
    /// A magazine.
    case Magazine = "magazine"
    /// Comics collected into a TPB.
    case TradePaperback = "trade paperback"
    /// Comics sold as a hardcover TPB.
    case Hardcover = "hard cover"
    /// I don't know what a Marvel digest is.
    case Digest = "digest"
    /// Marvel Graphic Novels, such as 'Marvels'.
    case GraphicNovel = "graphic novel"
    /// Comics sold digitally.
    case DigitalComic = "digital comic"
    /// Marvel comics released under the 'Infinite' imprint.
    case InfiniteComic = "infinite comic"
}

//	MARK: Marvel API Comic Format Type Enum

/**
    `MarvelAPIComicFormatType`

    Defines the format type for the comics requested in the query.
    Each case maps to it's representation as a URL parameter.
*/
enum MarvelAPIComicFormatType: String {
    /// The stand alone comic.
    case Comic = "comic"
    /// A collection of the comics.
    case Collection = "collection"
}

//	MARK: Marvel API Comic Query Protocol

/**
    `MarvelAPIComicQuery`

    Builds on the MarvelAPIQuery as a query specifically about Marvel comics.
*/
protocol MarvelAPIComicQuery: MarvelAPIQuery {
}

extension MarvelAPIComicQuery {
    /// The API endpoint path for queries about Marvel comics.
    var endpointAPIPath: String { return "/v1/public/comics" }
}

//	MARK: Marvel API Comic Book Query Struct

/**
    `MarvelAPIComicBookQuery`

    Represents a query about comics books to Marvel's API.
    This allows for specifying the number of comic books to be fetched as well as the date range for those comic books.
*/
struct MarvelAPIComicBookQuery: MarvelAPIComicQuery {
    
    //	MARK: Constants
    
    private let comicFormat = MarvelAPIComicFormat.Comic
    private let comicFormatType = MarvelAPIComicFormatType.Comic
    
    //	MARK: Variable Properties
    
    /// The parameters for this query. Restricted access to keep the parameter types safe (we only want comic and general parameters).
    var parameters: [MarvelAPIQueryParameter] {
        return internalParameters
    }
    /// The internal storage for the parameters.
    private var internalParameters = [MarvelAPIQueryParameter]()
    
    //	MARK: Initialization
    
    init() {
        //  default the parameters to contain the speific format and format type that we care about
        internalParameters = [MarvelAPIComicQueryParameter.Format(comicFormat), MarvelAPIComicQueryParameter.FormatType(comicFormatType)]
    }
    
    //	MARK: Parameter Management
    
    /**
        Add a general query parameter to this query.
    
        - Parameter parameter:  The general parameter to add to this query.
     */
    mutating func addParameter(parameter: MarvelAPIGeneralQueryParameter) {
        internalParameters.append(parameter)
    }
    
    /**
        Add a comic specific query parameter to this query.
     
        - Parameter parameter:  The comic query parameter to add to this query.
     */
    mutating func addParameter(parameter: MarvelAPIComicQueryParameter) {
        internalParameters.append(parameter)
    }
}