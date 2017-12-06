//
//  ApiCall.swift
//  YVFourSquareTrendingVenues
//
//  Created by Yash Vyas on 06/12/17.
//  Copyright © 2017 Yash Vyas. All rights reserved.
//

import UIKit

// MARK: - FourSquare Client Id and Secret
let client_id = "LHD5XJ3ZAJTIO0IMXY12NIMYSLOSGYJCTYYJN1WJMD4PJ4XT" // visit developer.foursqure.com for API key
let client_secret = "I0SATNN3JW0CHHDXZQ2AN1K0AKCFXLMFKLO4OGC1I41UF005" // visit developer.foursqure.com for API key

class ApiCall: NSObject {
    
}

// MARK: - API Calls
extension NSObject {
    
    // Cancel All Active Request
    func cancelAllRunningRequest(completion: @escaping (_ finished: Bool) -> Void) {
        
        URLSession.shared.getTasksWithCompletionHandler {
            dataTasks, uploadTasks, downloadTasks in
            
            for i in 0 ..< dataTasks.count {
                dataTasks[i].cancel()
            }
            completion(true)
        }
    }
    
    func getTrendingVenues() {
        
        guard let viewController = self as? ViewController else {
            return
        }
        
        viewController.tblVenues.isHidden = true
        viewController.lblCurrentLocation.superview?.isHidden = true
        
        let url = "https://api.foursquare.com/v2/venues/trending?ll=\(viewController.currentLocation.latitude),\(viewController.currentLocation.longitude)&limit=50&client_id=\(client_id)&client_secret=\(client_secret)&v=20171206"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            if let jsonData = data {
                
                do {
                    viewController.arrSearchResults = try JSONDecoder().decode(Venues.self, from: jsonData).response.venues
                } catch {
                    print(error.localizedDescription)
                }
                
                // set label name and visible
                DispatchQueue.main.async {
                    if let currentVenueName = viewController.arrSearchResults.first?.name {
                        viewController.lblCurrentLocation.text = "You're at \(currentVenueName).\nHere're some trending venues nearby."
                    } else if viewController.arrSearchResults.count == 0 {
                        viewController.lblCurrentLocation.text = "No Data Available"
                    }
                    viewController.lblCurrentLocation.superview?.isHidden = false
                    viewController.tblVenues.isHidden = false
                    viewController.tblVenues.reloadData()
                }
            }
        })
        
        cancelAllRunningRequest { (finished) in
            if finished {
                task.resume()
            }
        }
    }
    
    func searchForVenue() {
        
        guard let viewController = self as? ViewController else {
            return
        }
        
        viewController.tblVenues.isHidden = true
        viewController.lblCurrentLocation.superview?.isHidden = true
        
        let url = "https://api.foursquare.com/v2/venues/search?ll=\(viewController.currentLocation.latitude),\(viewController.currentLocation.longitude)&limit=100&client_id=\(client_id)&client_secret=\(client_secret)&v=20171206&query=" + (viewController.searchController?.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            if let jsonData = data {
                
                do {
                    
                    viewController.arrSearchResults = try JSONDecoder().decode(Venues.self, from: jsonData).response.venues
                    
                    DispatchQueue.main.async {
                        if let currentVenueName = viewController.arrSearchResults.first?.name {
                            viewController.lblCurrentLocation.text = "You're at \(currentVenueName).\nHere're some similar venues nearby."
                        } else if viewController.arrSearchResults.count == 0 {
                            viewController.lblCurrentLocation.text = "No Data Available"
                        }
                        viewController.lblCurrentLocation.superview?.isHidden = false
                        viewController.tblVenues.isHidden = false
                        viewController.tblVenues.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
        
        cancelAllRunningRequest { (finished) in
            if finished {
                task.resume()
            }
        }
    }
}
