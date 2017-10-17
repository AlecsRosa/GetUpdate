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
    
    static var blockAction: (()->())?
    

    
    
    // MARK: Init
    
    public class func setup(token: String) {
        UpdateManager.token = token
    }
    
    
    // MARK: UIAlertController
    
    private class func showAlert(update: Update, alertType: AlertType) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        switch alertType {
        case .update:
            
//            guard
//                update.update != UpdateType.optional.rawValue ||
//                update.update == UpdateType.optional.rawValue && UpdateManager.canShowGetUpdate(before: UpdateManager.getMuteFrom())
//                else { return }

            
            let Title: String = "Versione \(update.version!) disponibile"
            let Message: String = "Una nuova versione di \(update.app!.name!) è disponibile sull'App Store.\nAggiorna per scoprire le funzionalità introdotte"
            
            let ActionAskLaterTitle: String = "Chiedimelo più tardi"
            let ActionUpdateTitle: String = "Aggiorna"
            
            let actionAskLater = UIAlertAction(title: ActionAskLaterTitle, style: .default) { (action) in
                UpdateManager.setMuteFrom()
                
                if let block = UpdateManager.blockAction {
                    block()
                }
            }
            
            let actionUpdate = UIAlertAction(title: ActionUpdateTitle, style: .default) { (action) in
                self.openStore(app: update.app)
                
                if let block = UpdateManager.blockAction {
                    block()
                }
            }
            
            alert.title = Title
            alert.message = Message
            
            if update.update == UpdateType.optional.rawValue { alert.addAction(actionAskLater) }
            alert.addAction(actionUpdate)
            
        case .alert:
            let Title: String = "🎉 La tua app è aggiornata!"
            let Message: String = "\nNovità in questa versione:\n\n" + update.description!
            let ActionOkTitle: String = "Ok, ho capito"
            
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
            UIApplication.shared.openURL(storeURL)
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
    
    public class func askForUpdate(block: (()->())? = nil) {
        UpdateManager.blockAction = block
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
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
                        print("Nessun aggiornamento disponibile.")
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


extension UpdateManager {
    
    class var now: Date { return Date() }
    class var day: Int { return 60 * 60 * 24 } // 60 * 60 * 24
    
    class func dateToMillis(date: Date) -> Int {
        return Int(date.timeIntervalSince1970)
    }
    
    class func canShowGetUpdate(before: Int) -> Bool {
        print(dateToMillis(date: now) - before)
        return (dateToMillis(date: now) - before) > day
    }
    
    class func setMuteFrom() {
        let pref = UserDefaults()
        pref.set(UpdateManager.dateToMillis(date: Date()), forKey: "GET_UPDATE_MUTE")
        pref.synchronize()
    }
    
    class func getMuteFrom() -> Int {
        let pref = UserDefaults()
        return pref.integer(forKey: "GET_UPDATE_MUTE")
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
