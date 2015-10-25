//
//  NPETLicenceViewController.swift
//  NowPlayingEveryTime
//
//  Created by 박성민 on 2015. 10. 25..
//  Copyright © 2015년 RickyPark. All rights reserved.
//

import Foundation
import UIKit

final class NPETLicenseViewController : UIViewController {
    
    @IBOutlet weak var licenseTextView:UITextView!
    var licenseData:NSDictionary?
    
    override func viewDidLoad() {
        if let firstText = licenseData?.allValues.first {
            licenseTextView.text = firstText as! String
        }
    }
}
