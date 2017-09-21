//
//  Update.swift
//  Update
//
//  Created by Alessandro Rosa on 20/07/2017.
//  Copyright © 2017 Fuoricittà S.r.l.s. All rights reserved.
//

class Update {
    
    var id: Int?
    var app: App?
    var version: String?
    var description: String?
    var update: String?
    var alert: String?

    
    init() {}
    
    init(version: String, description: String, app: App) {
        self.version = version
        self.description = description
        self.app = app
    }
    
    class func map(JSON: [String: Any], block:(_ update: Update)->()) {
        let update = Update()
        
        update.version = JSON["version"] as? String
        update.description = JSON["description"] as? String
        update.update = JSON["update"] as? String
        update.alert = JSON["alert"] as? String
        
        App.map(JSON: JSON["app"] as! [String: Any], block: { (app) in
            update.app = app
            
            block(update)
        })
    }
}
