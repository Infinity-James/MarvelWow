//
//  AppDelegate.swift
//  MarvelWow
//
//  Created by James Valaitis on 02/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import SwiftyDropbox
import UIKit

//	MARK: App Delegate

/**
    `AppDelegate`
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //	MARK: Constants
    
    /// The unique Dropbox key for this app.
    private let dropboxAppKey = "u0knwvsgquitsth"
    
    //	MARK: Properties
    
    var window: UIWindow?

    //	MARK: UIApplicationDelegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //  set up Dropbox
        Dropbox.setupWithAppKey(dropboxAppKey)
        
        return true
    }
}