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
    
    var thxToCount:Int = 0
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        getSettingsDataFromPlist()
    }
    
    public override func viewWillAppear(animated: Bool) {
        thxToCount = 0
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

                if indexPath.row == 0 {
                    cell!.detailTextLabel?.text = (NSUserDefaults.standardUserDefaults().objectForKey("NPETDivider") as? String) ?? "_"
                }
            }
        }
        
        return cell!;
    }

    func didDividerConfirmAlertHandler(alert: UIAlertAction!) {
        tableView!.reloadData()
    }

    func didDividerSelectedHandler(alert: UIAlertAction!) {
        NSUserDefaults.standardUserDefaults().setObject(alert.title!, forKey: "NPETDivider")
        
        let titleString:String = String(format: "Divider is set to %@", arguments: [alert.title!])
        let resultShowAlertController:UIAlertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
        let okayAction:UIAlertAction = UIAlertAction(title: "Okay", style: .Default, handler: didDividerConfirmAlertHandler)

        resultShowAlertController.addAction(okayAction)
        self.presentViewController(resultShowAlertController, animated: true, completion: nil)
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // show action sheet to select one of "_", "-", or "/". Default value is "_".
            let selectDividerActionSheet:UIAlertController = UIAlertController(title: "Select one in this list", message: nil, preferredStyle: .ActionSheet)
            let underscoreSelectedAction:UIAlertAction = UIAlertAction(title: "_", style: UIAlertActionStyle.Default, handler: didDividerSelectedHandler)
            let slashSelectedAction:UIAlertAction = UIAlertAction(title: "/", style: UIAlertActionStyle.Default, handler: didDividerSelectedHandler)
            let hyphenSelectedAction:UIAlertAction = UIAlertAction(title: "-", style: UIAlertActionStyle.Default, handler: didDividerSelectedHandler)
            let cancelSelectedAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            selectDividerActionSheet.addAction(underscoreSelectedAction)
            selectDividerActionSheet.addAction(slashSelectedAction)
            selectDividerActionSheet.addAction(hyphenSelectedAction)
            selectDividerActionSheet.addAction(cancelSelectedAction)
            
            self.presentViewController(selectDividerActionSheet, animated: true, completion:nil)
            
            break;
        case 1:
            performSegueWithIdentifier("NPETShowLicenseSequeIdentifier", sender: self)
            
            break;
            
        case 2:
            let messageText:String = (thxToCount == 5 ? "Sweetest \"My Love\", and YOU!" : "YOU who are using NPET!")
            
            let thxAlertController = UIAlertController(title: "Special Thanks To..", message:messageText , preferredStyle: .Alert)
            thxAlertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(thxAlertController, animated: true, completion: { () -> Void in
                self.thxToCount++
                
                if self.thxToCount > 5 {
                    self.thxToCount = 0
                }
            })
        default:
            break;
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Read from the Configuration plist the data to make the state of the object valid.
        if let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle") {
            if let ackDict = NSDictionary(contentsOfFile:path.stringByAppendingString("/en.lproj/Acknowledgements.strings")) {
                print(ackDict)
                
                let licenseVC = segue.destinationViewController as! NPETLicenseViewController
                licenseVC.licenseData = ackDict
            }
        }
    }
}
