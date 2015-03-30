//
//  SecondMasterViewController.swift
//  Fonts
//
//  Created by Liu Bing on 3/30/15.
//  Copyright (c) 2015 UnixOSS. All rights reserved.
//

import UIKit

class SecondMasterViewController: UITableViewController {
    
    var fontFamilyIndex: Int = 0
    var language: String?
    var fontFamilyArray: [String: [CTFontDescriptorRef]]?
    private var fontFamilies: [String]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = language
        
        if let keys = fontFamilyArray?.keys {
            fontFamilies = Array(keys)
        }
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: fontFamilyIndex), atScrollPosition: .Top, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fontFamilyArray?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fontFamily = fontFamilies?[section]
        let fontArray = fontFamily != nil ? fontFamilyArray?[fontFamily!] : nil
        return fontArray?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fontFamilies?[section]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let fontFamily = fontFamilies?[indexPath.section]
        let fontArray = fontFamily != nil ? fontFamilyArray?[fontFamily!] : nil
        let fontDescriptor = fontArray?[indexPath.row]
        let kCTFontVisibleNameAttribute = "NSFontVisibleNameAttribute"
        let downloaded = CTFontDescriptorCopyAttribute(fontDescriptor, kCTFontDownloadedAttribute) as Bool
        cell.textLabel?.text = CTFontDescriptorCopyLocalizedAttribute(fontDescriptor, kCTFontVisibleNameAttribute, nil) as? String
        cell.accessoryType = downloaded ? .Checkmark : .None

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                let fontFamily = fontFamilies?[indexPath.section]
                let fontArray = fontFamily != nil ? fontFamilyArray?[fontFamily!] : nil
                controller.fontDescriptor = fontArray?[indexPath.row]
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}
