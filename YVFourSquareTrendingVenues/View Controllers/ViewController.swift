//
//  ViewController.swift
//  YVFourSquareTrendingVenues
//
//  Created by Yash Vyas on 05/12/17.
//  Copyright © 2017 Yash Vyas. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tblVenues: UITableView!
    @IBOutlet weak var lblCurrentLocation: UILabel!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    var searchController: UISearchController? = nil
    var arrSearchResults: [Venue] = []
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Venues"
        
        currentLocation = CLLocationCoordinate2D(latitude: 28.4771109, longitude: 77.0769104)
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Do any additional setup after loading the view, typically from a nib.
        
        lblCurrentLocation.superview?.isHidden = true
        tblVenues.isHidden = true
        
        tblVenues.estimatedRowHeight = 64
        tblVenues.rowHeight = UITableViewAutomaticDimension
        
        tblVenues.tableFooterView = UIView()
        
        getCurrentLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Request location access
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Methods
    // Figure out where the user is
    func getCurrentLocation() {
        // Check if location access is granted
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                break
            default:
                showLocationAlert()
            }
        } else {
            showLocationAlert()
        }
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable location for YVFourSquareTrendingVenues", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            self.lblCurrentLocation.superview?.isHidden = false
            self.tblVenues.isHidden = false
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
            searchController?.searchBar.delegate = self
            searchController?.dimsBackgroundDuringPresentation = false
        }
        self.navigationItem.searchController = searchController
        searchController?.isActive = true
    }
}

// MARK: - Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            getTrendingVenues()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last, location.timestamp.timeIntervalSinceNow >= -30.0, location.horizontalAccuracy <= 80 else {
            return
        }
        
        currentLocation = location.coordinate
        if arrSearchResults.count == 0 {
            getTrendingVenues()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - Search Bar Delegate
extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.searchController = nil
        getTrendingVenues()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if ((text.count == 0 && range.length == 1) || (range.location >= 2)) && text != "\n"{
            searchForVenue()
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            getTrendingVenues()
        }
    }
}

// MARK: - Table View Delegate and Data Source
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Set up the SearchCells with data from the searchResults array
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell

        let venue = arrSearchResults[indexPath.row]
        cell.title.text = venue.name
        
        if let rating = venue.rating {
            cell.rating.text = String(format: "%.1f", rating) + "⭐️"
            cell.rating.isHidden = false
        } else {
            cell.rating.isHidden = true
        }
        
        if let location = venue.location {
            cell.distance.text = "\(location.distance ?? 0)m"
            cell.address.text = location.address
        }
        
        return cell
    }
    
}
