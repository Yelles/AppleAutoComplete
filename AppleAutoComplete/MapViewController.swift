//
//  MapViewController.swift
//  AppleAutoComplete
//
//  Created by Anthony H on 10/28/18.
//  Copyright © 2018 Anthony H. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapViewOutlet: MKMapView!
    
    var locationManager: CLLocationManager!
    let regionRadius: CLLocationDistance = 100
    var placeMark:MKPlacemark? = nil
    var selectedTitle = String()
    
    //Helpers
    var showAlert = AlertsViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // set initial location to selected place
        let initialLocation = CLLocation(latitude: (self.placeMark?.coordinate.latitude)!, longitude: (self.placeMark?.coordinate.longitude)!)
        print("The lat is \(self.placeMark!.coordinate.latitude)")
        
        if checkLocationPermission() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()


            centerMapOnLocation(location: initialLocation)
            
            let selectedPlace = MKPointAnnotation()
            selectedPlace.title = self.placeMark?.title
            selectedPlace.coordinate = (self.placeMark?.coordinate)!
            
            //drop a pin in the selected location
            mapViewOutlet.addAnnotation(selectedPlace)
        }
        else {
            
            self.displayLocationAlert()
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Custom Methods
    
    func displayLocationAlert() {
        
        let title = "Location Services Not Enabled"
        let message = "You can enable location services for AvMed in Privacy Settings"
        
        showAlert.showAlert(titleString: title, messageString: message, fromController: self)
        
    }
    
    // Center the map on the selected location
    func centerMapOnLocation(location: CLLocation) {

        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 100, longitudinalMeters: regionRadius * 100)
        mapViewOutlet.setRegion(coordinateRegion, animated: true)
    }
    

    // MARK: - Map delegates
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
        
        let title = "Error"
        let message = error.localizedDescription
        
        showAlert.showAlert(titleString: title, messageString: message, fromController: self)

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        
        
    }
    
    // MARK: - Annotation View
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let selectedLoc = view.annotation
        
        self.placeMark = MKPlacemark(coordinate: (selectedLoc?.coordinate)!, addressDictionary: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //print("you selected a pin")
        //get the title of the selected item so we can pass it to map directions
        selectedTitle = ((view.annotation?.title)!)!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapViewOutlet.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.blue
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        
        let point = CGPoint(x: 0,y :0)
        let button = UIButton(frame: CGRect(origin: point, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
    
    @objc func getDirections(){
        if let selectedPin = placeMark {
            let mapItem = MKMapItem(placemark: selectedPin)
            mapItem.name = selectedTitle
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    
    
}
