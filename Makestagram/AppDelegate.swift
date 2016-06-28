//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse // import the Parse SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    // set up the Parse SDK
    let configuration = ParseClientConfiguration { (configuration) -> Void in
        configuration.applicationId = "makestagram"
        configuration.server        = "https://makestagram-parse-guti.herokuapp.com/parse"
    }
    
    // initialize it
    Parse.initializeWithConfiguration(configuration)
    
    // login with test credentials
    do {
        try PFUser.logInWithUsername("test", password: "test")
    } catch {
        print("Unable to log in")
    }
    
    // check if login was successful
    if let currentUser = PFUser.currentUser() {
        print("\(currentUser.username!) logged in successfully")
    } else {
        print("No logged in user :(")
    }
    
    // change the default ACL(Access Control Lists) lists of user that have 
    // certain rights to read, modigy, or delete certain objects.
    let acl = PFACL()
    acl.publicReadAccess = true
    PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

