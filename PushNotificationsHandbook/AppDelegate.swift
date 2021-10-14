//
//  AppDelegate.swift
//  PushNotificationsHandbook
//
//  Created by Yair Carreno on 29/05/21.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        print("_:didFinishLaunchingWithOptions")
        print(launchOptions ?? "")

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        // Used for testing purposes
        // debugOperation("didFinishLaunchingWithOptions")
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }

    // MARK: Remote Push Notifications
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenComponents = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenComponents.joined()
        print("Success in registering for remote notifications with token \(deviceTokenString)")
        //Send the token to save/update on the server here!

        // Used for testing purposes
        // debugOperation("didRegisterForRemoteNotificationsWithDeviceToken")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }

    // MARK: Silent Push Notifications
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        print("_:didReceiveRemoteNotification:fetchCompletionHandler")
        print(userInfo)
        // Used for testing purposes
        // debugOperation("didReceiveRemoteNotification")
        completionHandler(.newData)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("willPresent: UNNotification")
        print(userInfo)
        // Used for testing purposes
        // debugOperation("willPresent")
        if #available(iOS 14.0, *) {
            completionHandler([[.banner, .list, .sound]])
        } else {
            completionHandler([[.alert, .sound]])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
                                    @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("didReceive: UNNotificationResponse")
        print(userInfo)
        // Used for testing purposes
        // debugOperation("didReceive")
        guard let score = userInfo["score"] as? String,
              let country = userInfo["country"] as? String else {
            completionHandler()
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var receiver: PushReceiverViewController

        if #available(iOS 13.0, *) {
            receiver = storyboard.instantiateViewController(identifier: "PushReceiverViewController") as PushReceiverViewController
        } else {
            receiver = storyboard.instantiateViewController(withIdentifier: "PushReceiverViewController") as! PushReceiverViewController
        }

        receiver.score = score
        receiver.country = country
        UIApplication.shared.windows.first?.rootViewController = receiver
        UIApplication.shared.windows.first?.makeKeyAndVisible()

        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //Send the token generated by FCM to save/update on the server here!
        
        // Used for testing purposes
        // debugOperation("messaging")
    }
}

extension AppDelegate : DebugWithRealTimeDB {
    func debugOperation(_ nameOperation: String) {
        Database.database().reference()
            .child("debug-push-notifications")
            .child(nameOperation)
            .setValue("operation called at \(Int64(Date().timeIntervalSince1970 * 1000))")
    }
}

protocol DebugWithRealTimeDB {
    func debugOperation(_ nameOperation: String)
}
