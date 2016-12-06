//
//  MiscUtils.swift
//  BikersMap
//
//  Created by Tasvir H Rohila on 22/11/16.
//  Copyright © 2016 Tasvir H Rohila. All rights reserved.
//

import Foundation
import UIKit

//Quick display of an alert box
func showAlert(callingVC: UIViewController, title:String, message:String) {
     let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
     
     let OK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
     alert.addAction(OK)
     
     //#COMMENTED as it gives warning "view is not in the window hierarchy"
     ///alert.show(true)
     callingVC.presentViewController(alert, animated: true, completion: nil)
}
