//
//  App.swift
//  Update
//
//  Created by Alessandro Rosa on 20/07/2017.
//  Copyright © 2017 Fuoricittà S.r.l.s. All rights reserved.
//

class App {
    
    var id: Int?
    var token: String?
    var url: String?
    var name: String?
    var description: String?
    var image: String?
    var storeType: Int?
    var storeId: String?
    var pushKey: Int?
    var team: Int?

    
    init() {

    }
    
    
    class func map(JSON: [String: Any], block:(_ app: App)->()) {
        let app = App()
        
        app.name = JSON["name"] as? String
        app.storeId = JSON["store_id"] as? String
        
        block(app)
    }
    
}
