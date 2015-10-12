//
//  NPETSettingsViewController.swift
//  NowPlayingEveryTime
//
//  Created by 박성민 on 2015. 8. 23..
//  Copyright (c) 2015년 RickyPark. All rights reserved.
//

import UIKit

public class NPETSettingsViewController : UITableViewController {
    
    let SettingsCellIdentifier:String = "SettingsCellIdentifier"
    
    var settingsDict:NSDictionary = NSDictionary()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        getSettingsDataFromPlist()
    }
    
    
    @IBAction func closeSettingsTapped(sender: AnyObject) {
        print("close")
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    private func getSettingsDataFromPlist() {
        
        if let settingsFilePath:String = NSBundle.mainBundle().pathForResource("SettingsList", ofType: "plist") {
            settingsDict = NSDictionary(contentsOfFile: settingsFilePath)!
        }
        
        if settingsDict.count > 0 {
            tableView!.reloadData()
        }
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsDict.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        cell = (tableView.dequeueReusableCellWithIdentifier(SettingsCellIdentifier) as UITableViewCell?)
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: SettingsCellIdentifier)
        }
        
        for settingsKey in settingsDict.allKeys {
            let parsedKey = (settingsKey.componentsSeparatedByString(". ") as Array)
            if Int(parsedKey.first!) == (indexPath.row + 1) {
                cell!.textLabel?.text = parsedKey.last
            }
        }
        
        return cell!;
    }
    
    func someHandler(alert: UIAlertAction!) {
        NSUserDefaults.standardUserDefaults().setObject(alert.title!, forKey: "NPETDivider")
        
        let titleString:String = String(format: "Divider is set to %@", arguments: [alert.title!])
        UIAlertView(title: titleString, message: nil, delegate: nil, cancelButtonTitle: "Okay").show()
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // show action sheet to select one of "_", "-", or "/". Default value is "_".
            let selectDividerActionSheet:UIAlertController = UIAlertController(title: "Select one in this list", message: nil, preferredStyle: .ActionSheet)
            let underscoreSelectedAction:UIAlertAction = UIAlertAction(title: "_", style: UIAlertActionStyle.Default, handler: someHandler)
            let slashSelectedAction:UIAlertAction = UIAlertAction(title: "/", style: UIAlertActionStyle.Default, handler: someHandler)
            let hyphenSelectedAction:UIAlertAction = UIAlertAction(title: "-", style: UIAlertActionStyle.Default, handler: someHandler)
            
            selectDividerActionSheet.addAction(underscoreSelectedAction)
            selectDividerActionSheet.addAction(slashSelectedAction)
            selectDividerActionSheet.addAction(hyphenSelectedAction)
            
            self.presentViewController(selectDividerActionSheet, animated: true, completion:nil)
            
            break;
        case 1:
            break;
        default:
            break;
        }
    }
}
