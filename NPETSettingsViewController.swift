//
//  NPETSettingsViewController.swift
//  NowPlayingEveryTime
//
//  Created by 박성민 on 2015. 8. 23..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

import UIKit

public class NPETSettingsViewController : UITableViewController {
    
    var settingsData:NSDictionary = NSDictionary()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        getSettingsDataFromPlist()
    }
    
    
    @IBAction func closeSettingsTapped(sender: AnyObject) {
        print("close")
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    private func getSettingsDataFromPlist() {
        tableView!.reloadData()
    }
}
