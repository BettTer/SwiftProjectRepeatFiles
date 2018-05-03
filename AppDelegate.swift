//
//  AppDelegate.swift
//  BombGame
//
//  Created by Tbxark on 24/01/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let appKey =
    let channel = ""
    let isProduction = true
    var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    
    static let projectName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    
    var window: UIWindow?
    var allowRotation: Bool?
    
    /// JPush方法
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        JPUSHService.handleRemoteNotification(userInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kJPFOpenNotification), object: userInfo)
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
        
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        JPUSHService.handleRemoteNotification(userInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kJPFOpenNotification), object: userInfo)
        completionHandler()
    }
    
    // MARK: - AppDelegate
    // 第一
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        // 登录操作
        Request.doesRecordAction = true
        
        self.switchController()
        return true
    }
    
    // 退出第一
    func applicationWillResignActive(_ application: UIApplication) {
        Request.recordAction(.signOut)
    }
    
    // 退出第二
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    // 第二
    func applicationDidBecomeActive(_ application: UIApplication) {
        Request.recordAction(.signIn)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    
    // MARK: - 转换控制器方法
    func switchController() -> Void {
        SVProgressHUD.show()
        self.setRotation(true)
        
        var rootViewController = UIViewController.initVControllerFromStoryboard("ViewController")
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
        
        
        
        Request.judgeDoesNeedUpdateViewController(Date.init(year: 2018, month: 4, day: 30)) {
            self.setRotation(false)
            
            let jsCodeLocation = CodePush.bundleURL()
            rootViewController = UIViewController.init()
            
            DispatchQueue.main.sync {
                let rootView = RCTRootView.init(bundleURL: jsCodeLocation, moduleName: AppDelegate.projectName, initialProperties: nil, launchOptions: self.launchOptions)
                rootView?.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
                rootViewController.view = rootView
                
                SVProgressHUD.showSuccess(withStatus: "已成功切换")
                DelayTask.createTaskWith(workItem: {
                    SVProgressHUD.dismiss()
                }, delayTime: 2.0)
                
                self.window?.rootViewController = rootViewController
            }
        }
        
        SVProgressHUD.dismiss()
    }
    
    
    // MARK: - 处理横竖屏转换方法
    func setRotation(_ doesAllowRotation: Bool) -> Void {
        self.allowRotation = doesAllowRotation
        self.application(UIApplication.shared, supportedInterfaceOrientationsFor: self.window)
    }
    
    
    /// 代理
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.allowRotation == false || self.allowRotation == nil {
            return UIInterfaceOrientationMask.portrait
            
        } else {
            return UIInterfaceOrientationMask.landscapeRight
            
        }
        
    }
    
}



