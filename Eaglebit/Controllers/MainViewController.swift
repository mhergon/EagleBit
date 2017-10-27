//
//  MainViewController.swift
//  Eaglebit
//
//  Created by mhergon on 22/10/17.
//  Copyright © 2017 mhergon. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Default methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            mapView.isHidden = true
        #endif

    }
    
    func setup() {
        
        let alwaysItem = UIBarButtonItem(title: "Auth", style: .plain, target: self, action: #selector(requestAlways))
        let start = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startLocation))
        navigationItem.leftBarButtonItems = [alwaysItem, start]
        
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteAllLocations))
        let showAll = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(showLocations))
        navigationItem.rightBarButtonItems = [delete, showAll]
        
    }
    
    @objc func requestAlways() {
        
        Eagle.authorize(level: .always) { (status) in
            
            switch status {
            case .authorizedWhenInUse:
                print("in use")
            case .authorizedAlways:
                print("always")
            case .denied:
                print("denied")
            case .notDetermined:
                print("not determined")
            case .restricted:
                print("restricted")
            }
            
        }
        
    }
    
    @objc func startLocation() {

        /// Start location updates
        Eagle.fly { (location, error) in
            
            if let last = location {
                
                // Save
                Location(from: last, activity: Eagle.activityType).save()
                
            }
        }
        
    }
    
    @objc func showLocations() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let locations = Location.all()
        var annotations = [MKPointAnnotation]()
        for loc in locations {
            
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            //pin.title = DateFormatter.localizedString(from: loc.timeStamp, dateStyle: .short, timeStyle: .short) + "\n\(loc.speed) m/s" + "\n" + loc.activityType
            pin.title = loc.activityType + "\n\(loc.speed) m/s"
            annotations.append(pin)
            
        }
        
        mapView.addAnnotations(annotations)
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
        
    }
    
    @objc func deleteAllLocations() {
        
        Location.deleteAll()
        showLocations()
        
    }

}

