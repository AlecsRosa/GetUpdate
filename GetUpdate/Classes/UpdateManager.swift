//
//  ViewController.swift
//  Update
//
//  Created by Alessandro Rosa on 20/07/2017.
//  Copyright © 2017 Fuoricittà S.r.l.s. All rights reserved.
//

import UIKit

public class UpdateManager: NSObject, URLSessionDelegate {
    
    enum AlertType { case update, alert }
    enum UpdateType: String { case none = "none", required = "required" , optional = "optional" }
    
    static let BaseUrl: String = "http://app.getupdate.it/"
    static let Endpoint: String = "api/v1/updates/"

    static var UUID = UIDevice.current.identifierForVendor!.uuidString
    static var currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    static var token: String?

    
    
    // MARK: Init
    
    public class func setup(token: String) {
        UpdateManager.token = token
    }
    

    // MARK: UIAlertController

    private class func showAlert(update: Update, alertType: AlertType) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        switch alertType {
        case .update:
            let Title: String = "New version \(update.version!) available"
            let Message: String = "A new version of \(update.app!.name!) is available on the App Store. Get the latest features to bla bla bla.."
            
            let ActionAskLaterTitle: String = "Ask me later"
            let ActionUpdateTitle: String = "Update"

            let actionAskLater = UIAlertAction(title: ActionAskLaterTitle, style: .default, handler: nil)
            let actionUpdate = UIAlertAction(title: ActionUpdateTitle, style: .default) { (action) in
                self.openStore(app: update.app)
            }
            
            alert.title = Title
            alert.message = Message
            
            if update.update == UpdateType.optional.rawValue { alert.addAction(actionAskLater) }
            alert.addAction(actionUpdate)
            
        case .alert:
            let Title: String = "🎉 Your App is up to date!"
            let Message: String = "\nWhat's new in this version:\n\n" + update.description!
            let ActionOkTitle: String = "Got it"
            
            let actionOk = UIAlertAction(title: ActionOkTitle, style: .default, handler: nil)
            
            alert.title = Title
            alert.message = Message
            
            alert.addAction(actionOk)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Utility
    
    private class func openStore(app: App?) {
        guard let appID = app?.storeId else { return }
        let storeURL = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    // MARK: URLSessionDelegate
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            
            completionHandler(.useCredential, credential)
        }
    }


    // MARK: Network
    
    public class func askForUpdate() {
        print("ASK")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self as? URLSessionDelegate, delegateQueue: nil)
    
        guard let URL = URL(string: UpdateManager.BaseUrl + UpdateManager.Endpoint + UpdateManager.token! + "/" + UpdateManager.UUID + "/" + UpdateManager.currentVersion! + "/") else { return }
        
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    
                    if let updateJSON = json["update"] as? [String: Any] {
                        Update.map(JSON: updateJSON, block: { (update) in
                            
                            if update.update != UpdateType.none.rawValue {
                                self.showAlert(update: update, alertType: .update)
                            }
                        })
                        
                    } else if let alertJSON = json["alert"] as? [String: Any] {
                        Update.map(JSON: alertJSON, block: { (update) in
                            
                            if update.alert != UpdateType.none.rawValue {
                                self.showAlert(update: update, alertType: .alert)
                            }
                        })
                    
                    } else {
                        print("No Update Available.")
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
                
            } else {
                // Failure
                print(error!.localizedDescription);
            }
        })
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
}



protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}

extension URL {
    
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}
