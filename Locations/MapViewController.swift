//
//  ViewController.swift
//  Locations
//
//  Created by Michael Tirenin on 8/18/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
// codefellows: 47.623575, -122.336067

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    var context : NSManagedObjectContext!
    var fetchedResultsController : NSFetchedResultsController!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Map"

        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus{
        case .Authorized, .AuthorizedWhenInUse:
            println("authorized (even when in use)")
            self.mapView.showsUserLocation = true
//            self.locationManager.startUpdatingLocation()
        case .Denied:
            println("denied - ask user about turning it on")
        case .NotDetermined:
            println("not determined - on first launch")
//            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestAlwaysAuthorization()
        case .Restricted:
            println("restricted")
        }
        
//        var location = CLLocationCoordinate2D(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
//        self.mapView.region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)

        self.latitudeTextField.delegate = self
        self.longitudeTextField.delegate = self

        var ground = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0444)
        var eye = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0442)
        
        var camera = MKMapCamera(lookingAtCenterCoordinate: ground, fromEyeCoordinate: eye, eyeAltitude: 50)
        self.mapView.camera = camera
        
        //setup our longpress gesture recognizer
        var longPress = UILongPressGestureRecognizer(target: self, action: "mapPressed:")
        self.mapView.addGestureRecognizer(longPress)
        
        self.mapView.delegate = self
        
        // get MoC from app delegate
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.context = appDelegate.managedObjectContext
        
        // setup fetched results controller
        var request = NSFetchRequest(entityName: "Reminder")
        let sort = NSSortDescriptor(key: "message", ascending: true)
        
        // add sort to the request
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        // initialize the fetched results controller
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // perform fetch on appearance
        var error : NSError?
        fetchedResultsController.performFetch(&error)
        if error != nil {
            println("error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func remindersButton(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("ToReminders", sender: self)
    }

//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if segue.identifier == "ToReminders" {
////            let remindersVC = segue.destinationViewController as RemindersViewController
////            var reminder = self.fetchedResultsController.fetchedObjects(Reminder)
////            remindersVC.selectedReminder = reminder
//        }
//    }
    
    func mapPressed(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            println("began")
            // where user touched on the mapView
            var touchPoint = sender.locationInView(self.mapView)
            var touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            // setting up pin
            var annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Add Reminder"
            annotation.subtitle = "Message"
            self.mapView.addAnnotation(annotation)
        case .Changed:
            println("changed")
        case .Ended:
            println("ended")
        default:
            println("default")
        }
    }
    
//    func mapPanned(sender : UIPanGestureRecognizer) {
//        switch sender.state {
//        case .Changed:
//            var point = sender.translationInView(self.view)
//            println(point)
//        default:
//            println("Default")
//        }
//    }

    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized, .AuthorizedWhenInUse:
            println("authorized (even when in use)")
            self.mapView.showsUserLocation = true
//            self.locationManager.startUpdatingLocation()
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
            println("lat: " + "(location.coordinate.latitude)")
            println("long: " + "(location.coordinate.longitude)")
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // similar to tableview cell for row at indexpath
        // first try to dequeue an old one
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
            // if not, create one with an identifier
            self.setupAnnotationView(annotationView)
            return annotationView
        } else {
            var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            self.setupAnnotationView(annotationView)
            return annotationView
        }
    }
    
    func setupAnnotationView(annotationView : MKPinAnnotationView) {
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        var rightButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
        annotationView.rightCalloutAccessoryView = rightButton
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        // tells which anntation was clicked
        var annotation = view.annotation
        
        var geoRegion = CLCircularRegion(center: annotation.coordinate, radius: 200, identifier: "Reminder")
        self.locationManager.startMonitoringForRegion(geoRegion)
        
        var newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.context) as Reminder
        newReminder.latitude = annotation.coordinate.latitude
        newReminder.longitude = annotation.coordinate.longitude
        newReminder.message = annotation.subtitle!
        
        println("annLat: \(annotation.coordinate.latitude)")
        println("annLong: \(annotation.coordinate.longitude)")
        println("annTitle: \(annotation.title!)")
        println("annMess: \(annotation.subtitle!)")
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("did enter region")
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("did EXIT region")
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func goThereButton(sender: UIBarButtonItem) {
        
        var latitudeString = NSString(string: self.latitudeTextField.text)
        var latitude = latitudeString.doubleValue
        
        var longitudeString = NSString(string: self.longitudeTextField.text)
        var longitude = longitudeString.doubleValue
        
        var newLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        var region = MKCoordinateRegionMakeWithDistance(newLocation, 1000, 1000)
        
        self.mapView.setRegion(region, animated: true)
    }
}

