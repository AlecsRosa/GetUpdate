//
//  ViewController.swift
//  GetUpdate
//
//  Created by Alessandro Rosa on 09/21/2017.
//  Copyright (c) 2017 Alessandro Rosa. All rights reserved.
//

import UIKit
import GetUpdate

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UpdateManager.askForUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

