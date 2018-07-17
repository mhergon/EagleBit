//
//  Eaglebit.swift
//  Eaglebit
//
//  Created by mhergon on 24/10/17.
//  Copyright © 2017 mhergon. All rights reserved.
//

import CoreLocation

/// Level authorization.
///
/// - inUse: Only when app is in foreground
/// - always: Always (include in background)
public enum EagleAuthorization {
    case inUse
    case always
}

/// Global access
public let Eagle = EagleBit()

/// Main
public class EagleBit: NSObject {

    // MARK: - Public properties
    
    /// Authorization status closure
    public typealias EagleAuthorizationStatus = (CLAuthorizationStatus) -> Swift.Void
    
    /// Location closure
    public typealias EagleLocation = (CLLocation?, Error?) -> Swift.Void
    
    /// The minimum distance (measured in meters) an Eagle must move horizontally before an update event is generated.
    public var distanceFilter: CLLocationDistance = 10.0 {
        didSet {
            locationManager.distanceFilter = distanceFilter
        }
    }
    
    /// Desired accuracy
    public var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters {
        didSet {
            locationManager.desiredAccuracy = desiredAccuracy
        }
    }
    
    /// Show/hide background location indicator
    public var showsBackgroundLocationIndicator = false {
        didSet {
            if #available(iOS 11.0, *) { locationManager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator }
        }
    }
    
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
    
    /// Region radius
    fileprivate enum RegionRadius: Double {
        case tiny = 40.0
        case big = 80.0
    }
    
    /// Core config
    fileprivate lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.distanceFilter = distanceFilter
        manager.allowsBackgroundLocationUpdates = isBackgroundLocationUpdatesAllowed()
        manager.pausesLocationUpdatesAutomatically = true
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startMonitoringSignificantLocationChanges()
        return manager
    }()

}

// MARK: - Public use methods
public extension EagleBit {
    
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
        if untilMoves, let last = locationManager.location { addResumeRegions(over: last) }
        
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
fileprivate extension EagleBit {
    
    /// Create regions for resume paused location updates.
    ///
    /// - Parameter over: Last location
    func addResumeRegions(over: CLLocation) {
        
        var region = CLCircularRegion(center: over.coordinate, radius: RegionRadius.tiny.rawValue, identifier: "eaglebit.region.tiny")
        locationManager.startMonitoring(for: region)
        region = CLCircularRegion(center: over.coordinate, radius: RegionRadius.big.rawValue, identifier: "eaglebit.region.big")
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

    /// Adjust activity type
    func adjustActivityType(from location: CLLocation) {

        /// Retunr .other type if no speed
        guard let speed = locationManager.location?.speed else { return }
        
        switch speed {
        case let s where s >= minimumSpeed && s <= runningMaxSpeed:
            locationManager.activityType = .fitness
            
        case let s where s > runningMaxSpeed && s <= automotiveMaxSpeed:
            locationManager.activityType = .automotiveNavigation
            
        case let s where s > automotiveMaxSpeed:
            locationManager.activityType = .otherNavigation
            
        default:
            locationManager.activityType = .other
            
        }

    }
    
}

// MARK: - CLLocationManagerDelegate
extension EagleBit: CLLocationManagerDelegate {
    
    // MARK: - Authorization related
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        /// Send status to all suscribers.
        for block in authorizationBlocks { block?(status) }
        
    }
    
    // MARK: - Location updates related
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let last = locations.last else { return }
        
        /// Send last location to all suscribers.
        for block in locationBlocks { block(last, nil) }
        
        /// Adjust activity type
        adjustActivityType(from: last)
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        /// Send error (check authorization and, plist properties, etc) to all suscribers.
        for block in locationBlocks { block(nil, error) }
        
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
        /// Create circular region for monitoring.
        if let location = manager.location { addResumeRegions(over: location) }

    }
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {

        /// Delete existing regions.
        deleteResumeRegion()
        
    }
    
    // MARK: - Region monitoring related
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        /// Re-start location updates
        locationManager.startUpdatingLocation()
        
    }

}
