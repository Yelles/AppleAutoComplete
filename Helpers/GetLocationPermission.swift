//
//  GetLocationPermission.swift
//  AppleAutoComplete
//
//  Created by Anthony H on 10/28/18.
//  Copyright © 2018 Anthony H. All rights reserved.
//

import Foundation
import MapKit

func checkLocationPermission() -> Bool {
    
    let locationManager = CLLocationManager()
    var enabled = false
    
    
    if CLLocationManager.locationServicesEnabled() {
        switch(CLLocationManager.authorizationStatus()) {
        case .restricted, .denied:
            //print("No access")
            enabled = false
            
        case .notDetermined:
            //print("permission not determined")
            locationManager.requestWhenInUseAuthorization()
            enabled = checkLocationPermission()
            
        case .authorizedAlways, .authorizedWhenInUse:
            //print("Access")
            
            enabled = true
        }
    } else {
        //print("Location services are not enabled")
        enabled = false
    }
    
    return enabled
    
}//checkLocationPermission
