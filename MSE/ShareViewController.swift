//
//  ShareViewController.swift
//  MSE
//
//  Created by Stefan Liu on 2020/2/8.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData
import Foundation

class ShareViewController: SLComposeServiceViewController {

    private var urlString: String?
    private var textString: String?

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let contentTypeURL = kUTTypeURL as String
        let contentTypeText = kUTTypeText as String
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        for extensionItem in extensionItems {
            if let itemProviders = extensionItem.attachments as? [NSItemProvider] {
                for itemProvider in itemProviders {
                    if itemProvider.hasItemConformingToTypeIdentifier(contentTypeText) {
                        itemProvider.loadItem(forTypeIdentifier: contentTypeText, options: nil) { text, error in
                            if error == nil {
                                self.textString = text as? String
                                NSLog(self.textString!)
                            }
                        }
                    } else if itemProvider.hasItemConformingToTypeIdentifier(contentTypeURL) {
                        itemProvider.loadItem(forTypeIdentifier: contentTypeURL, options: nil) { text, error in
                            if error == nil {
                                let url = text as? URL
                                self.urlString = url?.absoluteString
                            }
                        }
                    }
                }
            }
        }


      // let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
      
      /*
      
      for attachment in extensionItem.attachments as! [NSExtensionItem] {
        attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
            if let url = results as! URL? {
                self.urlString = url.absoluteString
            }
        })
        attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
            if error == nil {
                self.textString = results as! String
                NSLog(self.textString!)
            }
        })
      }
      */
      
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // NSLog(self.textString!)
        // let url = URL(string: "maester://test")!
        let data = [
            "url": self.urlString!
        ];
        let payload = try! JSONSerialization.data(withJSONObject: data, options: []);
        let host = payload.base64EncodedString()
        let _ = self.openURL(URL(string: "maester://\(host)/newlink")!)
        self.dismiss(animated: false) {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

}
