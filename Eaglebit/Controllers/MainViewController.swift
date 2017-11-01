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
        
        var auth: EagleAuthorization = .inUse
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            auth = .always
        }
        
        Eagle.authorize(level: auth, status: nil)        
        
    }
    
    @objc func startLocation() {

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        delegate.startLocation()
        
    }
    
    @objc func showLocations() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let locations = Location.all()
        var annotations = [MKPointAnnotation]()
        for loc in locations {
            
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            pin.title = DateFormatter.localizedString(from: loc.timeStamp, dateStyle: .short, timeStyle: .short) + "\n\(loc.speed) m/s"
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

