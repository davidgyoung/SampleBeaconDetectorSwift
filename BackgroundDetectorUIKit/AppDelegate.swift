//
//  AppDelegate.swift
//  BackgroundDetectorUIKit
//
//  Created by David G. Young on 2/24/24.
//

import UIKit
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var uuid: String {
        get {
            return UserDefaults.standard.string(forKey: "uuid") ?? "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "uuid")
        }
    }
    var major1: UInt16 {
        get {
            return UInt16(UserDefaults.standard.string(forKey: "major1") ?? "1")!
        }
        set {
            UserDefaults.standard.setValue(String(newValue), forKey: "major1")
        }
    }
    var major2: UInt16 {
        get {
            return UInt16(UserDefaults.standard.string(forKey: "major2") ?? "1")!
        }
        set {
            UserDefaults.standard.setValue(String(newValue), forKey: "major2")
        }
    }    
    var minor1: UInt16 {
        get {
            return UInt16(UserDefaults.standard.string(forKey: "minor1") ?? "1")!
        }
        set {
            UserDefaults.standard.setValue(String(newValue), forKey: "minor1")
        }
    }
    var minor2: UInt16 {
        get {
            return UInt16(UserDefaults.standard.string(forKey: "minor2") ?? "2")!
        }
        set {
            UserDefaults.standard.setValue(String(newValue), forKey: "minor2")
        }
    }
    var vc: ViewController? = nil
    var locationManager: CLLocationManager!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let keys = launchOptions?.keys {
            NSLog("didFinishLaunchingWithOptions: \(String(describing: launchOptions))")
            for key in keys {
                var keyString = "other: \(key)"
                if key == .location {
                    keyString = "Location"
                    if let beaconRegion = launchOptions?[key] as? CLBeaconRegion {
                        NSLog("Key has value with a CLBeaconRegion with id: \(beaconRegion.identifier)")
                    }
                }
                if let value = launchOptions?[key] {
                    NSLog("key \(keyString) has value \(value)")
                }
                else {
                    NSLog("key \(keyString) has no value")
                }
            }
        }
        else {
            NSLog("didFinishLaunchingWithOptions: nil")
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                NSLog("error: \(error)")
            }
        }

        let locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager = locationManager
        
        if locationManager.authorizationStatus != .authorizedAlways  {
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                NSLog("Location is authorized when in use")
                NSLog("Requesting always authorization")
                locationManager.requestAlwaysAuthorization()
            }
            else {
                NSLog("Location is not authorized when in use")
                NSLog("Requesting when in use authorization")
                locationManager.requestWhenInUseAuthorization()
            }
        }
        else {
            NSLog("Location is authorized always")
        }
        startMonitoring()

        NSLog("didFinishLaunchingWithOptions end")
        return true
    }
    func restartMonitoring() {
        let uuid = UUID(uuidString: self.uuid)!
        
        let region1 = CLBeaconRegion(uuid: uuid, major: major1, minor: minor1, identifier: "region1")
        let region2 = CLBeaconRegion(uuid: uuid, major: major2, minor: minor2, identifier: "region2")
        locationManager.stopMonitoring(for: region1)
        locationManager.stopMonitoring(for: region2)
        startMonitoring()
    }
    func startMonitoring() {
        logEvent(line: "Trying to monitor \(uuid) \(major1) \(minor1) / \(major2) \(minor2)")
        NSLog("Monitored region initial count: \(self.locationManager.monitoredRegions.count)")
        let uuid = UUID(uuidString: self.uuid)!
        
        let region1 = CLBeaconRegion(uuid: uuid, major: major1, minor: minor1, identifier: "region1")
        let region2 = CLBeaconRegion(uuid: uuid, major: major2, minor: minor2, identifier: "region2")
        region1.notifyEntryStateOnDisplay = true
        region2.notifyEntryStateOnDisplay = true

        locationManager.startMonitoring(for: region1)
        locationManager.startMonitoring(for: region2)
        // This deprecated construct gives you extra 5 seconds of callbacks after a region transition
        locationManager.startRangingBeacons(in: region1)
        locationManager.startRangingBeacons(in: region2)
        // This construct does not give you extra callbacks after a region transition
        //locationManager.startRangingBeacons(satisfying: identityConstraint)
        NSLog("Monitored region end count: \(locationManager.monitoredRegions.count)")
    }
    func getLog() -> String {
        return UserDefaults.standard.string(forKey: "log") ?? ""
    }
    func logEvent(line: String) {
        let df = DateFormatter()
        df.dateFormat = "MM/dd H:mm:ss.SSSS"
        let timestampString = df.string(from: Date())
        let timestampedLine = "\(timestampString) \(line)\n"
        var log = getLog()
        var lines = log.split(separator: "\n")
        if lines.count > 1000 {
            while lines.count >= 1000 {
                lines.remove(at: 999)
            }
            log = lines.joined(separator: "\n")
        }
        log = timestampedLine+log
        UserDefaults.standard.setValue(log, forKey: "log")
        vc?.updateLog(log: log)
    }
    func clearLog() {
        UserDefaults.standard.setValue("", forKey: "log")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location Manager Failed")
        logEvent(line: "didFailWithError: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        NSLog("Started monitoring")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NSLog("Entered region")
        sendNotification(message: "Beacon Detected")
        logEvent(line: "didEnterRegion: \(region.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("Exited region")
        sendNotification(message: "Beacon Not Detected")
        logEvent(line: "didExitRegion: \(region.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        NSLog("Determined state for region: \(state)")
        var stateString = "???"
        if state == .inside {
            stateString = "inside"
        }
        if state == .outside {
            stateString = "outside"
        }
        if state == .unknown {
            stateString = "unknown"
        }

        logEvent(line: "didDetermine \(region.identifier) \(stateString)")
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            NSLog("Ranged beacon from region with major \(beacon.major), minor \(beacon.minor), rssi: \(beacon.rssi)")
        }
        if beacons.count == 0 {
            NSLog("Ranged 0 beacons from region")
        }
    }
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            NSLog("Ranged beacon from identity constraint with major \(beacon.major), minor \(beacon.minor), rssi: \(beacon.rssi)")
        }
        if beacons.count == 0 {
            NSLog("Ranged 0 beacons from identity constraint")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        NSLog("Ranging failed")
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        NSLog("Monitoring failed")
        logEvent(line: "monitoringDidFail: \(region), \(error)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func sendNotification(message: String) {
        // disable this to not be annoying
        return
        DispatchQueue.main.async {
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()
            let content = UNMutableNotificationContent()
            content.title = message
            content.body = ""
            //content.categoryIdentifier = "low-priority"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        }
    }



}

