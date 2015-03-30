//
//  MasterViewController.swift
//  Fonts
//
//  Created by Liu Bing on 3/30/15.
//  Copyright (c) 2015 UnixOSS. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var fontDictionary = [String: [String : [CTFontDescriptorRef]]]()
    var languages: [String]?

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        activityIndicator.center = CGPoint(x: tableView.frame.width/2.0, y: 22)
        footerView.addSubview(activityIndicator)
        tableView.tableFooterView = footerView
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let descriptorOptions = [kCTFontDownloadableAttribute as String: true]
            let descriptor = CTFontDescriptorCreateWithAttributes(descriptorOptions)
            let fontDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as [CTFontDescriptorRef]
            fontDescriptors.map { fontDescriptor -> Void in
                let kCTFontDesignLanguagesAttribute = "NSCTFontDesignLanguagesAttribute"
                let languages = CTFontDescriptorCopyAttribute(fontDescriptor, kCTFontDesignLanguagesAttribute) as? [String]
                let fontFamily = CTFontDescriptorCopyLocalizedAttribute(fontDescriptor, kCTFontFamilyNameAttribute, nil) as? String ?? "other"
                languages?.map { language -> Void in
                    var fontFamilyArray = self.fontDictionary[language] ?? [String : [CTFontDescriptorRef]]()
                    var fontArray = fontFamilyArray[fontFamily] ?? [CTFontDescriptorRef]()
                    fontArray.append(fontDescriptor)
                    fontFamilyArray[fontFamily] = fontArray
                    self.fontDictionary[language] = fontFamilyArray
                }
                return
            }
            self.languages = Array(self.fontDictionary.keys)
            self.languages?.sort { $0 < $1 }
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.tableView.tableFooterView = nil
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let controller = segue.destinationViewController as SecondMasterViewController
                controller.fontFamilyIndex = indexPath.row
                let language = languages?[indexPath.section]
                controller.language = language
                controller.fontFamilyArray = language != nil ? fontDictionary[language!] : nil
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fontDictionary.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = languages?[section]
        let fonts = key != nil ? fontDictionary[key!] : nil
        return fonts?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return languages?[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return languages
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let key = languages?[indexPath.section]
        var fontFamilies: [String]?
        if key != nil {
            if let families = fontDictionary[key!]?.keys {
                fontFamilies = Array(families)
            }
        }
        cell.textLabel!.text = fontFamilies?[indexPath.row]
        return cell
    }

}

