//
//  MapSearchTable.swift
//  BikersMap
//
//  Created by Tasvir H Rohila on 20/11/16.
//  Copyright © 2016 Tasvir H Rohila. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapSearchTable: UITableViewController {
    
    //MARK: -
    //MARK: Properties
    var mapSearchController:UISearchController?
    //var mapSearchManager: MapSearchManager = MapSearchManager()
    
    //delegate for handling selection of location in search results
    var mapSearchDelegate: MapSearchDelegate?
    
    //MARK: -
    //MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: -
    //MARK: custom methods
    func initialize(onComplete: ()-> Void) {
        //getData(onComplete)
        self.tableView.reloadData()
    }
}

extension MapSearchTable : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        mapSearchController = searchController
        if let searchBarText = searchController.searchBar.text {
            MapSearchManager.sharedInstance().filterSearch(searchBarText)
        }
        self.tableView.reloadData()
    }
}

//MARK: -
//MARK: TableView data source and delegate methods
extension MapSearchTable {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapSearchManager.sharedInstance().bikeShareDataFiltered.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let data = MapSearchManager.sharedInstance().bikeShareDataFiltered[indexPath.row]
        cell.textLabel?.text = data.featureName
        cell.detailTextLabel?.text = "Number of empty slots: \(data.nbBikesAvailable)"
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = MapSearchManager.sharedInstance().bikeShareDataFiltered[indexPath.row]
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = data.location.coordinate
        annotation.title = data.featureName
        mapSearchDelegate?.dropPin(at: annotation, scale: data.nbBikesAvailable)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
