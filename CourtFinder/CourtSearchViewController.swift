//
//  CourtSearchViewController.swift
//  CourtFinder
//
//  Created by Christian Morte on 12/31/16.
//  Copyright © 2016 Christian Morte. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Court Search View Controller class
class CourtSearchViewController : UIViewController {
    
    // MARK: Constant Attributes
    let animationDuration = 0.3
    
    // MARK: Connected Handlers
    @IBOutlet weak var courtCancelButton: UIButton!
    @IBOutlet weak var courtSearchButton: UIButton!
    @IBOutlet weak var courtSearchBar: UISearchBar!
    @IBOutlet weak var courtSearchTableView: UITableView!
    
    var mapViewController: MapViewController? = nil
    var mainCourtSearchBarFrame: CGRect? = nil
    
    // MARK: - Override vars
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Init methods
    override func viewDidLoad() {
        super.viewDidLoad()
        courtSearchBar.delegate = self
        courtSearchTableView.delegate = self
        courtSearchTableView.dataSource = self
        
        courtCancelButton.alpha = 0
        courtSearchButton.alpha = 0
        
        print("Court Search View Controller did load")
    }
    
    func setMapViewController(mapViewController: MapViewController) {
        self.mapViewController = mapViewController
        mainCourtSearchBarFrame = self.mapViewController?.mainCourtSearchBar.frame
    }
    
    // MARK: - IBAction Methods
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        UIView.animate(withDuration: animationDuration, animations: hide, completion: resignSearchBarFocuses)
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        courtSearchBar.endEditing(true)
        hide()
        
        // Do some backend stuff to send to map view controller
    }
    
    // MARK: - Display/Hide Methods
    func display() -> Void {
        if (mapViewController != nil) {
            UIView.animate(withDuration: animationDuration, animations: animateDisplay, completion: assignCourtSearchBarFocus)
        }
    }
    
    func hide() {
        if (mapViewController != nil) {
            mapViewController?.mainCourtSearchBar.text = courtSearchBar.text
            
            courtCancelButton.alpha = 0
            courtSearchButton.alpha = 0
            
            removeFromParentViewController()
            view.removeFromSuperview()
        }
    }
    
    // MARK: Display/Hide Method Helpers
    private func animateDisplay() {
        // TODO: Better transition from main search bar to court search bar...
        
        mapViewController?.addChildViewController(self)
        view.frame = (mapViewController?.view.frame)!
        
        mapViewController?.view.addSubview(view)
        didMove(toParentViewController: mapViewController)
        
        courtCancelButton.alpha = 1
        courtSearchButton.alpha = 1

        courtSearchBar.text = mapViewController?.mainCourtSearchBar.text
    }
    
    private func assignCourtSearchBarFocus(completion: Bool) {
        let mainCourtSearchBar = mapViewController?.mainCourtSearchBar
        if (mainCourtSearchBar != nil) {
            mainCourtSearchBar?.resignFirstResponder()
        }
        courtSearchBar.becomeFirstResponder()
    }
    
    private func resignSearchBarFocuses(completion: Bool) {
        if (mapViewController != nil) {
            let mainCourtSearchBar = mapViewController?.mainCourtSearchBar
            
            if (mainCourtSearchBar != nil) {
                mainCourtSearchBar?.endEditing(true)
            }
             mapViewController?.view.endEditing(true)
        }
        courtSearchBar.resignFirstResponder()
    }
}

// MARK: - Search Bar Methods
extension CourtSearchViewController : UISearchBarDelegate {
    
    // MARK: Search Bar Delegate Methods
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        hide()
        
        // Do some backend stuff to send to map view controller
    }
}

// MARK: - Table View Methods
extension CourtSearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Two sections: Recent Sections, Search Results
        return 2
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        // TODO: Currently hard-coded, connect w/backend...
        if (section == 0) { // Recent searches section
            return 2
        }
        return 3    // Search results section
    }
    
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (section == 0) { // Recent searches section
            return "Recent Searches"
        }
        return "Search Results"    // Search results section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        if (indexPath.section == 0) {
            cell.textLabel?.text = "Hello World!"
        } else if (indexPath.section == 1) {
            cell.textLabel?.text = "Foo Bar."
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // TODO: Connect with backend/app to go to court info screen
        print("Selected cell at ", indexPath)
    }
    
    // MARK: Table View Delegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        courtSearchBar.endEditing(true)
    }
}
