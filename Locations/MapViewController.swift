//
//  ViewController.swift
//  Locations
//
//  Created by Michael Tirenin on 8/18/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
// codefellows: 47.623575, -122.336067

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
                            
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus{
        case .Authorized, .AuthorizedWhenInUse:
            println("authorized (even when in use)")
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        case .Denied:
            println("denied")
        case .NotDetermined:
            println("not determined - on first launch")
//            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestAlwaysAuthorization()
        case .Restricted:
            println("restricted")
        }
        
//        var location = CLLocationCoordinate2D(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
//        self.mapView.region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized, .AuthorizedWhenInUse:
            println("authorized (even when in use)")
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        case .Denied:
            println("denied")
        case .NotDetermined:
            println("not determined")
        case .Restricted:
            println("restricted")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // grab the last item (CLLocation object) in the array
        if let location = locations.last as? CLLocation {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
        }
    }

}

