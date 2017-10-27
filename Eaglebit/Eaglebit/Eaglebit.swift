//
//  Eaglebit.swift
//  Eaglebit
//
//  Created by mhergon on 24/10/17.
//  Copyright © 2017 mhergon. All rights reserved.
//

import Foundation
import CoreLocation

/// Level authorization.
///
/// - inUse: Only when app is in foreground
/// - always: Always (include in background)
enum EagleAuthorization {
    case inUse
    case always
}

/// Global access
let Eagle = Eaglebit()

/// Main
class Eaglebit: NSObject {

    // MARK: - Public properties
    
    /// Authorization status closure
    typealias EagleAuthorizationStatus = (CLAuthorizationStatus) -> Swift.Void
    
    /// Location closure
    typealias EagleLocation = (CLLocation?, Error?) -> Swift.Void
    
    /// The minimum distance (measured in meters) an Eagle must move horizontally before an update event is generated.
    var distanceFilter: CLLocationDistance = 10.0 {
        didSet {
            locationManager.distanceFilter = distanceFilter
        }
    }
    
    /// Show/hide background location indicator
    var showsBackgroundLocationIndicator = false {
        didSet {
            if #available(iOS 11.0, *) { locationManager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator }
        }
    }
    
    // FIXME: Delete
    var activityType = ""
    
    // MARK: - Private properties
    fileprivate var authorizationBlocks = [EagleAuthorizationStatus?]()
    fileprivate var locationBlocks = [EagleLocation]()
    
    /// Activity speeds (in m/s).
    ///
    /// - minimumSpeed: Minimum speed to consider moving
    /// - runningMaxSpeed: Maximum speed to consider running
    /// - automotiveMaxSpeed: Maximum speed to consider automotive
    fileprivate let minimumSpeed = 0.3
    fileprivate let runningMaxSpeed = 7.5
    fileprivate let automotiveMaxSpeed = 69.44
    
    /// Region for resumen location updates (minimum of 100 meters( is recommende)
    fileprivate let resumeRegionRadius = 100.0
    
    /// Core config
    fileprivate lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.distanceFilter = distanceFilter
        manager.allowsBackgroundLocationUpdates = isBackgroundLocationUpdatesAllowed()
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .other
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()

}

// MARK: - Public use methods
extension Eaglebit {
    
    // MARk: - Public methods
    
    /// Authorize device to receive location updates.
    ///
    /// - Parameters:
    ///   - level: Level of use (inUse or always)
    ///   - status: Current status
    func authorize(level: EagleAuthorization, status: EagleAuthorizationStatus?) {
        
        // Add to suscribers list
        authorizationBlocks.append(status)
        
        switch level {
        case .inUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    /// Start location updates.
    ///
    /// - Parameter over: Location updates closure
    func fly(over: @escaping EagleLocation) {
        
        // Add to suscribers list
        locationBlocks.append(over)

        // Start location updates
        locationManager.startUpdatingLocation()

    }
    
    /// Pause location updates until user moves or not.
    /// Set to "true" to restart when user moves or "false" to pause indefinitely.
    ///
    /// - Parameter untilMoves: true/false
    func stationary(untilMoves: Bool = true) {
        
        /// Add resume region to restart when user moves
        if untilMoves, let last = locationManager.location { addResumeRegion(over: last) }
        
        /// Pause updating location
        locationManager.stopUpdatingLocation()
        
    }
    
    /// Stop location updates
    func land() {
        
        /// Stop updates
        locationManager.stopUpdatingLocation()
        
        /// Remove resume region
        deleteResumeRegion()
        
        /// Remove observers
        locationBlocks.removeAll()
        
    }

}


// MARK: - Private methods
fileprivate extension Eaglebit {
    
    /// Create region for resume paused location updates.
    ///
    /// - Parameter over: Last location
    func addResumeRegion(over: CLLocation) {
        
        let region = CLCircularRegion(center: over.coordinate, radius: resumeRegionRadius, identifier: "eaglebit.region")
        locationManager.startMonitoring(for: region)

    }
    
    /// Delete all regions
    func deleteResumeRegion() {
        
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        
    }
    
    /// Determine authorization level
    ///
    /// - Returns: true/false
    func isBackgroundLocationUpdatesAllowed() -> Bool {
        
        return CLLocationManager.authorizationStatus() == .authorizedAlways
        
    }

    /// Adjust precion & battery power
    func adjustPrecisionAndBattery() {

        /// Retunr .other type if no speed
        guard let speed = locationManager.location?.speed else { return }
        
        switch speed {
        case let s where s >= 0.0 && s <= minimumSpeed:
            locationManager.activityType = .other
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            activityType = "unknown"
            
        case let s where s > minimumSpeed && s <= runningMaxSpeed:
            locationManager.activityType = .fitness
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            
            // FIXME: Delete
            showNotification(message: "adjustPrecisionAndBattery: walking or running")
            activityType = "walk"
    
        case let s where s > runningMaxSpeed && s <= automotiveMaxSpeed:
            locationManager.activityType = .automotiveNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // FIXME: Delete
            showNotification(message: "adjustPrecisionAndBattery: automotive")
            activityType = "automotive"
            
        case let s where s > automotiveMaxSpeed:
            locationManager.activityType = .otherNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // FIXME: Delete
            showNotification(message: "adjustPrecisionAndBattery: ludicrous")
            activityType = "ludicrous"
            
        default:
            locationManager.activityType = .other
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            
        }

    }
    
}

// MARK: - CLLocationManagerDelegate
extension Eaglebit: CLLocationManagerDelegate {
    
    // MARK: - Authorization related
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        /// Send status to all suscribers.
        for block in authorizationBlocks { block?(status) }
        
    }
    
    // MARK: - Location updates related
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /// Send last location to all suscribers.
        for block in locationBlocks { block(locations.last, nil) }
        
        /// Adjust precion & activity type to save battery
        adjustPrecisionAndBattery()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        /// Send error (check authorization and, plist properties, etc) to all suscribers.
        for block in locationBlocks { block(nil, error) }
        
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
        /// Create circular region for monitoring.
        if let location = manager.location { addResumeRegion(over: location) }
        
        // FIXME: Delete
        showNotification(message: "locationManagerDidPauseLocationUpdates")
        
    }
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
        /// Delete existing regions.
        deleteResumeRegion()

        // FIXME: Delete
        showNotification(message: "locationManagerDidResumeLocationUpdates")
        
    }
    
    // MARK: - Region monitoring related
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        /// Re-start location updates.
        manager.startUpdatingLocation()
        
        // FIXME: Delete
        showNotification(message: "didExitRegion")
        
    }

}


