//
//  MapSearchManagerTests.swift
//  BikersMap
//
//  Created by Tasvir H Rohila on 23/11/16.
//  Copyright © 2016 Tasvir H Rohila. All rights reserved.
//

import XCTest
@testable import BikersMap

let kDefaultWaitForExpectationsWithTimeout = 5.0

class MapSearchManagerTests: XCTestCase {
    
    var testBikeShareData: [BikeShareDataModel] = []
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        populateMockData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    /**
     Populate mock data
    */
    func populateMockData() {
        testBikeShareData.append(BikeShareDataModel(id: "2", featureName: "Harbour Town - Docklands Dve - Docklands", lat: -37.814022, long: 144.939521, nbBikesAvailable: 18))
        testBikeShareData.append(BikeShareDataModel(id: "3", featureName: "St Paul's Cathedral - Swanston St / Flinders St - City", lat: -37.814022, long: 144.939521, nbBikesAvailable: 8))
        testBikeShareData.append(BikeShareDataModel(id: "4", featureName: "Aquarium - Kings Way / Flinders St - City", lat: -37.814022, long: 144.939521, nbBikesAvailable: 10))
        testBikeShareData.append(BikeShareDataModel(id: "5", featureName: "Federation Square - Flinders St / Swanston St - City", lat: -37.814022, long: 144.939521, nbBikesAvailable: 15))
        MapSearchManager.sharedInstance().bikeShareData = testBikeShareData
    }
    /**
     Test for MapSearchManager->getData() function
     */
    func testGetData() {
        let asyncExpectation = expectationWithDescription("MapSearchManagerTests async request")

        MapSearchManager.sharedInstance().getData({
            XCTAssert(MapSearchManager.sharedInstance().bikeShareData.count > 0)
            asyncExpectation.fulfill()

        }) { (errorString) in
            XCTAssert(!errorString.isEmpty)
        }

        
        self.waitForExpectationsWithTimeout(kDefaultWaitForExpectationsWithTimeout) { error in
            XCTAssertNil(error, "MapSearchManagerTests: Could not download data")
        }

    }
    
    /**
     test for filtering search functionality
    */
    func testFilterSearch() {
        //Pass condition
        MapSearchManager.sharedInstance().filterSearch("Flind")
        XCTAssert(MapSearchManager.sharedInstance().bikeShareDataFiltered.count == 3)
        
        //Pass condition
        MapSearchManager.sharedInstance().filterSearch("Dock")
        XCTAssert(MapSearchManager.sharedInstance().bikeShareDataFiltered.count == 1)

        //Fail condition
        MapSearchManager.sharedInstance().filterSearch("Aqua")
        XCTAssert(MapSearchManager.sharedInstance().bikeShareDataFiltered.count > 1)
        
        //Pass condition
        MapSearchManager.sharedInstance().filterSearch("South")
        XCTAssert(MapSearchManager.sharedInstance().bikeShareDataFiltered.count == 0)
    }
}
