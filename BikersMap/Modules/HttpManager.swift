//
//  HttpManager.swift
//  BikersMap
//
//  Created by Tasvir H Rohila on 20/11/16.
//  Copyright © 2016 Tasvir H Rohila. All rights reserved.
//

import Foundation
import UIKit

//Structure to hold the API reponse
struct HttpApiResponse {
    var statusCode      :   Int?                    //HTTP status code
    var statusMessage   :   String                  //Server message
    var responseJSON    :   [String : AnyObject]?   //JSON
    var responseData    :   NSData?                 //Raw NSData
    var allHeaderFields :   [NSObject : AnyObject]? //Key = Value pairs of the http response
}

enum HTTPMethod: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
}

//The dafault key to be used for JSON result
let kDefaultJsonResultsKey = "kDefaultJsonResultsKey"

public class HttpManager {
    
    // Mark: Shared instance
    private static let theSharedInstance = HttpManager()
    
    // MARK: Public
    public static func sharedInstance() -> HttpManager {
        return theSharedInstance
    }
    
    /**
     Main function to fetch network data from server API
     
     - parameter isHttpPOST: Bool
     - parameter theURL:String URL of the end-point
     - parameter onSuccess:((HttpApiResponse?)->())? callback closure for Success
     - parameter onFailure:((HttpApiResponse)->()? callback closure for failure
     */
    func getData(httpMethod: HTTPMethod,
                    theURL:String,
                    onSuccess:((HttpApiResponse)->())?,
                    onFailure: ((HttpApiResponse)-> ())? )
    {
        let request = NSMutableURLRequest(URL: NSURL(string: theURL)!)
        request.HTTPMethod = httpMethod.rawValue

        self.showNetworkActivityIndicator(true)
        
        //start the session with given request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                debugPrint("postData error=\(error)")
                self.showNetworkActivityIndicator(false)
                onFailure?(HttpApiResponse(statusCode: -1,
                    statusMessage: error?.localizedDescription ?? "Unknown server error",
                    responseJSON: nil,
                    responseData: nil,
                    allHeaderFields: [:]))
                return
            }
            self.showNetworkActivityIndicator(false)

            self.handleHTTPDataResponse(data,
                                        response: response,
                                        error: error,
                                        onSuccess: onSuccess,
                                        onFailure: onFailure)
            
        }
        task.resume()
    }

    /**
     Helper method to handle HTTP response data from the API
     
     - parameter data: optional NSData as part of the response body
     - parameter response: NSURLResponse from the remote server
     - parameter error: NSError object containing the error details
     - parameter onSuccess:((HttpApiRespons?)->())? callback closure for Success
     - parameter onFailure:(((HttpApiResponse))->()? callback closure for failure
     */
    func handleHTTPDataResponse(data: NSData?,
                                response: NSURLResponse?,
                                error: NSError?,
                                onSuccess:((HttpApiResponse)->())?,
                                onFailure: ((HttpApiResponse)-> ())? )
    {
        
        if let httpStatus = response as? NSHTTPURLResponse {
            if httpStatus.statusCode != 200 && httpStatus.statusCode != 201 {           // check for http errors
                debugPrint("statusCode should be 200 or 201, but is \(httpStatus.statusCode)")
                debugPrint("response = \(response)")
                //let responseData = self.parseJSON(data!)
                let statusMessage = "Unknown server error."
                onFailure?(HttpApiResponse(statusCode: httpStatus.statusCode, statusMessage: statusMessage, responseJSON: nil, responseData: nil, allHeaderFields: [:]))
            }
            else {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let responseData = self.parseJSON(data!)
                let statusMessage = "Unknown server error."
                let httpResponse: HttpApiResponse = HttpApiResponse(statusCode: httpStatus.statusCode, statusMessage: statusMessage, responseJSON: responseData, responseData: data, allHeaderFields: httpStatus.allHeaderFields)
                debugPrint("responseString = \(responseString)")
                debugPrint("responseJSON =", responseData)
                debugPrint("response Headers = ",httpStatus.allHeaderFields)

                onSuccess?(httpResponse)
            }
        }
    }

    /**
     Parse the JSON data that has been retrieved from the API
     
     - parameter data: The response data of type NSData
     - returns: array of [String: AnyObject]
     */
    func parseJSON(data: NSData) -> [String: AnyObject] {
        var results:[String: AnyObject] = [:]
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            debugPrint("json = \(json)")
            if let jsonDict = json as? [String:AnyObject] {
                results = jsonDict
            } else {
                if let jsonArray = json as? [AnyObject] {
                    results = [kDefaultJsonResultsKey: jsonArray]
                }
            }
        } catch {
            debugPrint("Error in HttpManager::parseJSON()")
        }
        return results
    }
    
    /**
     sets the visible state of network activity indicator in top status-bar
     
     - parameter isVisible: Bool to set the visible state of network activity indicator
     */
    func showNetworkActivityIndicator(isVisible: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = isVisible
    }

}
