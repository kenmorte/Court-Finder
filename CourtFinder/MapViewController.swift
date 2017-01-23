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
    let courtSearchViewController: CourtSearchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CourtSearchViewController") as! CourtSearchViewController
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainCourtSearchBar: UISearchBar!
    @IBOutlet weak var mainCourtSearchFilterButton: UIButton!
    
    // MARK: - Override vars
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mainCourtSearchBar.delegate = self
        courtSearchViewController.setMapViewController(mapViewController: self)
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
            mapView.setRegion(region, animated: true)
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension MapViewController : UISearchBarDelegate {
    internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        NSLog("did begin editing")
        courtSearchViewController.setMapViewController(mapViewController: self)
        courtSearchViewController.display()
    }
}

