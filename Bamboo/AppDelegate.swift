//
//  AppDelegate.swift
//  Bamboo
//
//  Created by 박태현 on 2015. 12. 14..
//  Copyright © 2015년 ParkTaeHyun. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //기본 탭바 틴트를 흰샛으로 변경
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)

        if launchOptions != nil {
            NSNotificationCenter.defaultCenter().postNotificationName("myNotif", object: nil, userInfo: nil)
        }
        //앱 최초실행인지 판단하는 코드
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let rootView = storyboard.instantiateViewControllerWithIdentifier("FirstRunViewController") as UIViewController
            if let window = self.window {
                window.rootViewController = rootView
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
            print(uuid)
            let jsonParser = SimpleJsonParser()
            
            jsonParser.HTTPGetJson("http://ec2-52-68-50-114.ap-northeast-1.compute.amazonaws.com/bamboo/API/Bamboo_Get_MyInfo.php?uuid=\(uuid)") {
                (data : Dictionary<String, AnyObject>, error : String?) -> Void in
                if error != nil {
                    print("\(error) : AppDelegate")
                } else {
                    if let uuid = data["m_uuid"] as? String,
                        let point = data["m_point"] as? String,
                        let univ = data["m_univ"] as? String {
                            User.sharedInstance().uuid = uuid
                            User.sharedInstance().point = point
                            User.sharedInstance().univ = univ
                    } else {
                        //print("User객체 SimpleJsonParser인스턴스 failed")
                    }
                }
            }
            if launchOptions != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("myNotif", object: nil, userInfo: nil)
            }
            sleep(1)
        }
        
        let types:UIUserNotificationType = ([.Alert, .Sound])
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        Apns.sharedInstance().deviceToken = deviceTokenString
        
        Alamofire.request(Router.UpdateDeviceToken(uuid: User.sharedInstance().uuid, deviceToken: Apns.sharedInstance().deviceToken))
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print( "노티피케이션 APNS 등록 중 에러 발생 :  \(error.localizedDescription)" )
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName("myNotif", object: nil, userInfo: userInfo as [NSObject : AnyObject])
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

