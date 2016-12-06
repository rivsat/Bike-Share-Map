//
//  MapSearchManager.swift
//  BikersMap
//
//  Created by Tasvir H Rohila on 20/11/16.
//  Copyright © 2016 Tasvir H Rohila. All rights reserved.
//

import Foundation

public class MapSearchManager {
    // Mark: -
    /// Mark : Properties
    // Mark: Shared instance
    private static let theSharedInstance = MapSearchManager()
    
    var bikeShareData: [BikeShareDataModel] = []
    var bikeShareDataFiltered: [BikeShareDataModel] = []
    
    // MARK: Public
    public static func sharedInstance() -> MapSearchManager {
        return theSharedInstance
    }
    
    func getData(onSuccess: ()-> Void, onFailure: (String) -> Void) {
        let theURL = BIKE_SHARE_API
        HttpManager.sharedInstance().getData(.Get,
                                             theURL: theURL,
                                             onSuccess: { (apiResponse) in
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    //Populate the bike share data
                                                    self.populateData(apiResponse)
                                                    onSuccess()
                                                })
        }) { (apiResponse) in
            //Failure. Signal back onFailure to calling program
            onFailure(apiResponse.statusMessage)
        }
    }
    
    func populateData(apiResponse: HttpApiResponse) {
        if let allItems = apiResponse.responseJSON?[kDefaultJsonResultsKey] as? [[String: AnyObject]] {
            for item in allItems {
                if let _bikeShareData = BikeShareDataModel(json: item) {
                    bikeShareData.append(_bikeShareData)
                }
            }
        }
        bikeShareDataFiltered = bikeShareData
    }
    
    //Filter the search results by the inputted search String
    func filterSearch(searchString: String) {
        bikeShareDataFiltered.removeAll()
        bikeShareDataFiltered = bikeShareData.filter{ $0.featureName.lowercaseString.containsString(searchString.lowercaseString) }
    }

}
