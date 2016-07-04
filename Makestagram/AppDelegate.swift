//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse // import the Parse SDK
import FBSDKCoreKit
import ParseUI
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var window: UIWindow?
    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()

        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize ParseLoginHelper with callback
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            } else if let _ = user {
                // login successful, display TabBarController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController")
                
                self.window?.rootViewController!.presentViewController(tabBarController, animated: true, completion: nil)
            }
        }
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.

        // set up the Parse SDK
        let configuration = ParseClientConfiguration { (configuration) -> Void in
            configuration.applicationId = "makestagram"
            configuration.server        = "https://makestagram-parse-guti.herokuapp.com/parse"
        }
    
        // initialize it
        Parse.initializeWithConfiguration(configuration)
        
        // change the default ACL(Access Control Lists) lists of users that have
        // certain rights to read, modify, or delete certain objects.
        let acl = PFACL()
        acl.publicReadAccess = true
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        // Initialize Facebook
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // Check for logged in user
        let user = PFUser.currentUser()
        let startViewController: UIViewController
        
        if (user != nil) {
            // set TabBarController as initial view controller
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyBoard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        } else {
            // Othewise set LoginViewController as first
            let loginViewController = PFLogInViewController()
            loginViewController.fields = [.UsernameAndPassword, .LogInButton,
                                          .SignUpButton, .PasswordForgotten,
                                          .Facebook]
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController?.delegate = parseLoginHelper
            
            startViewController = loginViewController
        }
        
        // Display the view controller
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController//;
        self.window?.makeKeyAndVisible()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    } // application()

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
    
    // MARK: - Facebook Integration
    
    func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()

    }

    func application(application: UIApplication, openURL url: NSURL,
                     sourceApplication: String?, annotation: AnyObject)-> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL:url, sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

