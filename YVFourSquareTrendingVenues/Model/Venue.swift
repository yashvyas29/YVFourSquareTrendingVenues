//
//  Venue.swift
//  YVFourSquareTrendingVenues
//
//  Created by Yash Vyas on 06/12/17.
//  Copyright © 2017 Yash Vyas. All rights reserved.
//

import UIKit

struct VenuesResponse: Codable {
    var venues: [Venue]
}

struct Venues: Codable {
    var response: VenuesResponse
}

struct Venue: Codable {
    
    // MARK: - Properties
    var name: String?
    var rating: Double?
    var location: Location?
}

struct Location: Codable {
    
    // MARK: - Properties
    var distance: Int?
    var address: String?
}
