import UIKit
import Flutter
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDNbeNlSQb8NyHK-z-JlVQWicssGnzyJms")
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound]) { _, _ in }
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - URL Handling (Google Sign-In + Firebase Phone Auth)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Auth.auth().canHandle(url) { return true }
    return GIDSignIn.sharedInstance.handle(url)
  }

  // MARK: - APNs Token — tell BOTH Messaging and Auth
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
  }

  // MARK: - Silent Push — let Firebase Auth intercept first
  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(userInfo) {
      completionHandler(.noData)
      return
    }
    Messaging.messaging().appDidReceiveMessage(userInfo)
    completionHandler(.noData)
  }

  // MARK: - Foreground Notification
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
    completionHandler([.banner, .sound])
  }

  // MARK: - Notification Tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
    completionHandler()
  }
}