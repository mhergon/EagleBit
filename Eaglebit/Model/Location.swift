//
//  Location.swift
//  Eaglebit
//
//  Created by mhergon on 22/10/17.
//  Copyright © 2017 mhergon. All rights reserved.
//

import Foundation
import CoreLocation

/// Location model for testing
struct Location: Codable {
    var latitude = 0.0
    var longitude = 0.0
    var speed = 0.0
    var timeStamp = Date()
    var activityType = "default"
    
    init(from location: CLLocation, activity: String) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        speed = location.speed
        timeStamp = location.timestamp
        activityType = activity
    }
    
    func save() {
        
        var allLocations = Location.all()
        allLocations.append(self)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(allLocations) {
            UserDefaults.standard.set(encoded, forKey: "locations")
        }
        
    }
    
    static func all() -> [Location] {

        guard let locations = UserDefaults.standard.value(forKey: "locations") as? Data else {
            return []
        }

        let decoder = JSONDecoder()
        let locationsDecoded = try! decoder.decode(Array.self, from: locations) as [Location]
        print(locationsDecoded)
        return locationsDecoded
        
    }
    
    static func deleteAll() {
        
        UserDefaults.standard.removeObject(forKey: "locations")
        
    }
    
}


