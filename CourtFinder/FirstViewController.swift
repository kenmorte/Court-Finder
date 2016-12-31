//
//  FirstViewController.swift
//  CourtFinder
//
//  Created by Christian Morte on 12/31/16.
//  Copyright © 2016 Christian Morte. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    
    var resultSearchController: UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableViewController")
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        
        // Embed search bar within navigation bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for courts"
        mapView.addSubview((resultSearchController?.searchBar)!)
        
        // Determines whether navigation bar disappears when search results shown
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        // Determines whether background dimmed when search results shown
        resultSearchController?.dimsBackgroundDuringPresentation = true
        
        // IMPORTANT: Limits overlap area to just View Controller's frame
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            let location = locations.first!
            let span = MKCoordinateSpanMake(0.05,0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span:span)
            
            // Set the initial zoomed region of the user's current location
            mapView.setRegion(region, animated: false)
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

