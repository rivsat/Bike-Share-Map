//
//  BikeShareDataModel.swift
//  BikersMap
//
//  Created by Tasvir H Rohila on 20/11/16.
//  Copyright © 2016 Tasvir H Rohila. All rights reserved.
//

import Foundation
import MapKit

struct Coordinates {
    let longitude: Double
    let latitude: Double
    init?(json: [String: AnyObject]?) {
        guard let _points = json?["coordinates"] as? [Double] else {
            return nil
        }
        longitude = _points[0]
        latitude = _points[1]
    }
}

struct BikeShareDataModel {
    let id: String
    let featureName: String
    let location: CLLocation
    let nbBikesAvailable: Int
    
    init?(json: [String: AnyObject]) {
        guard let _id = json["id"] as? String,
            _featureName = json["featurename"] as? String,
            _coordinates = Coordinates(json: json["coordinates"] as? [String: AnyObject]),
            _nbNikesAvailable = json["nbbikes"] as? String
            else {
                return nil
        }
        id = _id
        featureName = _featureName
        location = CLLocation(latitude: _coordinates.latitude, longitude: _coordinates.longitude)
        nbBikesAvailable = Int(_nbNikesAvailable) ?? 0
    }
    
    init(id: String, featureName: String, lat: Double, long: Double, nbBikesAvailable: Int) {
        self.id = id
        self.featureName = featureName
        self.location = CLLocation(latitude: lat, longitude: long)
        self.nbBikesAvailable = nbBikesAvailable
    }
}
