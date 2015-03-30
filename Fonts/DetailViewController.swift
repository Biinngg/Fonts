//
//  DetailViewController.swift
//  Fonts
//
//  Created by Liu Bing on 3/30/15.
//  Copyright (c) 2015 UnixOSS. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var fontDescriptor: CTFontDescriptorRef?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progress = 0
        activityIndicator.startAnimating()
        textView.hidden = true
        
        var errorDuringDownload = false
        
        weak var weakSelf = self
        if var descriptor = fontDescriptor {
            let fontName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as String
            descriptor = CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute as String: fontName] as CFDictionaryRef)
            CTFontDescriptorMatchFontDescriptorsWithProgressHandler([descriptor], nil) { (state, progressParameter) -> Bool in
                dispatch_async(dispatch_get_main_queue()) {
                    switch state {
                    case .DidBegin:
                        weakSelf?.activityIndicator.startAnimating()
                        weakSelf?.activityIndicator.hidden = false
                        weakSelf?.textView.hidden = true
                    case .DidFinish:
                        weakSelf?.activityIndicator.stopAnimating()
                        weakSelf?.activityIndicator.hidden = true
                        let font = UIFont(descriptor: descriptor, size: 14)
                        weakSelf?.textView.font = font
                        weakSelf?.textView.hidden = false
                        
                        let fontRef = CTFontCreateWithFontDescriptor(descriptor, 0, nil)
                        let fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute) as NSURL
                        println("font url: \(fontURL)")
                        println("font ref: \(fontRef)")
                        
                        if !errorDuringDownload {
                            println("\(font.fontName) downloaded!")
                        }
                    case .WillBeginDownloading:
                        weakSelf?.progressView.progress = 0.0
                        weakSelf?.progressView.hidden = false
                    case .DidFinishDownloading:
                        weakSelf?.progressView.hidden = true
                    case .Downloading:
                        let progressValue = ((progressParameter as Dictionary)[kCTFontDescriptorMatchingPercentage as String] as? NSNumber)?.floatValue ?? 0.0
                        weakSelf?.progressView.setProgress(progressValue, animated: true)
                    case .DidFailWithError:
                        let error = (progressParameter as Dictionary)[kCTFontDescriptorMatchingError as String] as? NSError
                        let errorMessage = error?.description ?? "Error message is not available"
                        errorDuringDownload = true
                        println("Download error: \(errorMessage)")
                    default:
                        break
                    }
                }
                
                
                return true
            }
        }
    }
    
    

}

