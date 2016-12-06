//
//  MapViewController.swift
//  MyMapKitPOC
//
//  Created by Tasvir Rohila on 18/11/2016.
//  Copyright © 2016 Tasvir. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/**
 View controller class that shows the map with bike share locations
 */
class MapViewController: UIViewController {
    
    //MARK: -
    //MARK: Properties
    @IBOutlet weak var bikeMapView: MKMapView!
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController?
    var selectedAnnotation: MKPointAnnotation?
    var mapSearchTable: MapSearchTable?
    
    //MARK: -
    //MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Convenience method to initialize the locationManager, Map and SearchBar components
    */
    func initialize() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()


        initializeMapLocation()
        initializeSearchBar()
        
        //Setup the data required to plot our points
        setupData()
    }
    
    func initializeMapLocation() {
        // initialize the location to Melbourne, Aus
        let location = CLLocation(latitude: -37.8136, longitude: 144.9631)
        let radius: CLLocationDistance = 1000
        centerMap(onLocation: location, radius: radius)
    }
    
    func initializeSearchBar() {
        func configureSearchBar() {
            let searchBar = resultSearchController!.searchBar
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for bike share"
            navigationItem.titleView = resultSearchController?.searchBar
            
            //
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            resultSearchController?.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
        }
        
        //instantiate the MapSearchTable UITableViewController class
        mapSearchTable = storyboard!.instantiateViewControllerWithIdentifier("MapSearchTable") as! MapSearchTable
        resultSearchController = UISearchController(searchResultsController: mapSearchTable)
        resultSearchController?.searchResultsUpdater = mapSearchTable
        
        mapSearchTable?.mapSearchDelegate = self
        
        configureSearchBar()
    }
    
    /**
     Setup data.
     Request MapSearchManager to get data for bike share from the remote server API
    */
    func setupData() {
        //Request MapSearchManager to get data for bike share from the remote server API
        MapSearchManager.sharedInstance().getData({
            self.mapSearchTable?.initialize({ })
            self.plotPointsOnMap()
        }) { (errorString) in
            showAlert(self, title: "Bike Data Error", message: errorString)
        }

    }
    /**
     Place the pins on the map based on the locations received from API
    */
    func plotPointsOnMap() {
        for data in MapSearchManager.sharedInstance().bikeShareDataFiltered {
            let annotation = MKPointAnnotation()
            annotation.coordinate = data.location.coordinate
            annotation.title = data.featureName
            
            //Drop a pin at the location with circle as per scale = nbBikesAvailable
            self.dropPin(at: annotation, scale: data.nbBikesAvailable)
        }
    }
    
    /**
     Center the map to provided location
     
     - parameter location: CLlocation coordinate to center the map
     - parameter radius: CLLocationDistance, the radius of the circle
    */
    func centerMap(onLocation location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radius * 2.0, radius * 2.0)
        bikeMapView.setRegion(coordinateRegion, animated: true)
    }
    
    /**
     Show Apple map to navigate the user to the
    */
    func getDirections(){
        if let selectedAnnotation = selectedAnnotation {
            let placemark = MKPlacemark(coordinate: selectedAnnotation.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = selectedAnnotation.title
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
}

//MARK: -
//MARK: CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            bikeMapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
}

//MARK: -
//MARK: MapSearchDelegate
protocol MapSearchDelegate {
    func dropPin(at annotation:MKPointAnnotation, scale: Int)
}

extension MapViewController: MapSearchDelegate {
    func dropPin(at annotation:MKPointAnnotation, scale: Int) {
        let _scale: Double = scale == 0 ? 1.0 : Double(scale)
        // cache the pin
        selectedAnnotation = annotation

        bikeMapView.addOverlay(MKCircle(centerCoordinate: annotation.coordinate, radius: 10 * _scale))
        bikeMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05 / _scale, 0.05 / _scale)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        bikeMapView.setRegion(region, animated: true)
    }
}

//MARK: -
//MARK: MKMapViewDelegate
extension MapViewController : MKMapViewDelegate {
    /**
     When mapKit asks for a viewForAnnotation, provide a button with "direction" icons as left accessory view.
    */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.redColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "direction"), forState: .Normal)
        button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    //to draw circle
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleView = MKCircleRenderer(overlay: overlay)
            circleView.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            circleView.lineWidth = 0.5
            circleView.strokeColor = UIColor.blueColor()
            return circleView
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
