//
//  ViewController.swift
//  iGoogleMap
//
//  Created by Pramod Singh Rawat on 26/02/18.
//  Copyright © 2018 iPramodSinghRawat. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import CoreData

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}

class ViewController: UIViewController, CLLocationManagerDelegate,GMSMapViewDelegate{

    @IBOutlet var viewMap: GMSMapView!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapTypeBtn: UIButton!
    var didFindMyLocation = false
    var mapTasks = MapTasks()
    var userMarker: GMSMarker!
    
    var userLatitude: String!
    var userLongitude: String!
    var userPosition: CLLocationCoordinate2D!

    var travelMode = TravelModes.driving
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userMarker=GMSMarker();
        self.userMarker.title = "You"
        self.userMarker.icon = GMSMarker.markerImage(with: .red)
        
        self.locationManager.delegate = self
        self.viewMap.delegate = self
        
        self.viewMap.accessibilityElementsHidden = false
        self.viewMap.settings.compassButton = true
        self.viewMap.settings.myLocationButton = true
        self.viewMap.settings.scrollGestures = true
        self.viewMap.settings.zoomGestures = true
        self.viewMap.addSubview(self.mapTypeBtn)
        
        self.viewMap.isTrafficEnabled=true // Enable Road Trafiic
        
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            //locationManager.startUpdatingLocation()
            // print("non func locationManager")
        } else {
            //locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("viewDidDisappear")
        
        self.locationManager.stopUpdatingLocation()
        
        //self.mapTimer.invalidate()
        //self.mapTimer=nil
        //mapView.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print("observeValue")
        
        if !didFindMyLocation {
            //print("didFindMyLocation")
            
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            self.viewMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 16.0)
            self.viewMap.settings.myLocationButton = true
            
            self.userLatitude = String(myLocation.coordinate.latitude)
            self.userLongitude = String(myLocation.coordinate.longitude)
            didFindMyLocation = true
            
            //self.sActivityIndicator("Done", false)//testing
            //userCoordinateOrigin=userLatitude+","+userLongitude
            
            
        }
    }
    
    /*
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as CLLocation
            self.viewMap.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            self.viewMap.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    */
    
    /*Start: locationManager Functions */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways: fallthrough
        print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 2 // 2 Meter
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.startUpdatingLocation()
            self.viewMap.isMyLocationEnabled = true
            //self.locationUpdateTimer()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to initialize GPS: ", error.description)
    }
    /* Below function working while location changes */
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        print("locationManager update")
        for location in locations {
            userLatitude = String(location.coordinate.latitude)
            userLongitude = String(location.coordinate.longitude)
            
            /* Udatting User location on Map */
            let userPositionNw = CLLocationCoordinate2D(
                latitude: Double((userLatitude as NSString).doubleValue),
                longitude: Double((userLongitude as NSString).doubleValue))
            
            //self.updateUserMarker(coordinate: userPositionNw)
            self.userPosition=userPositionNw
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeMapType(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select Map Type:", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .normal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .terrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .hybrid
        }
        
        let satelliteMapTypeAction = UIAlertAction(title: "Satellite", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .satellite
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(satelliteMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    

}

