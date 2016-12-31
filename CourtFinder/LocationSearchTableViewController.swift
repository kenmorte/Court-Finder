//
//  LocationSearchTableViewController.swift
//  CourtFinder
//
//  Created by Christian Morte on 12/31/16.
//  Copyright © 2016 Christian Morte. All rights reserved.
//

import Foundation
import UIKit

class LocationSearchTableViewController : UITableViewController {
}

extension LocationSearchTableViewController : UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        print (searchController.searchBar.text ?? "N/A")
    }
}
