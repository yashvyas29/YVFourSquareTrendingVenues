//
//  ViewController.swift
//  YVFourSquareTrendingVenues
//
//  Created by Yash Vyas on 05/12/17.
//  Copyright © 2017 Yash Vyas. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - FourSquare Client Id and Secret
let client_id = "CLIENT_ID" // visit developer.foursqure.com for API key
let client_secret = "CLIENT_SECRET" // visit developer.foursqure.com for API key

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tblVenues: UITableView!
    @IBOutlet weak var lblCurrentLocation: UILabel!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    
    var arrSearchResults: [Venue] = []
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocation = CLLocationCoordinate2D(latitude: 28.4771109, longitude: 77.0769104)
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Do any additional setup after loading the view, typically from a nib.
        
        lblCurrentLocation.isHidden = true
        tblVenues.isHidden = true
        
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
        // check if access is granted
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
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
            self.lblCurrentLocation.isHidden = false
            self.tblVenues.isHidden = false
        }))
        present(alert, animated: true, completion: nil)
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
            cell.rating.text = String(format: "%.1f", Double(rating) ?? 0) + "⭐️"
        }
        
        if let location = venue.location {
            cell.distance.text = "\(Int(location.distance ?? "0") ?? 0)m"
            cell.address.text = location.address
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - API Calls
extension ViewController {
    
    func getTrendingVenues() {
        let url = "https://api.foursquare.com/v2/venues/trending?ll=\(currentLocation.latitude),\(currentLocation.longitude)&limit=50&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            if let jsonData = data {
                
                do {
                    self.arrSearchResults = try JSONDecoder().decode(Venues.self, from: jsonData).venues
                    
                    // set label name and visible
                    DispatchQueue.main.async {
                        if let currentVenueName = self.arrSearchResults.first?.name {
                            self.lblCurrentLocation.text = "You're at \(currentVenueName). Here's some trending venues nearby."
                        }
                        self.lblCurrentLocation.isHidden = false
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
        
        task.resume()
    }
    
    func searchForVenue() {
        let url = "https://api.foursquare.com/v2/venues/search?ll=\(currentLocation.latitude),\(currentLocation.longitude)&limit=100&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            if let jsonData = data {
                
                do {
                    self.arrSearchResults = try JSONDecoder().decode(Venues.self, from: jsonData).venues
                    
                    DispatchQueue.main.async {
                        self.tblVenues.isHidden = false
                        self.tblVenues.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
        
        task.resume()
    }
}
