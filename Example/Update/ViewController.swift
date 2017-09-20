//
//  ViewController.swift
//  Update
//
//  Created by Alessandro Rosa on 07/24/2017.
//  Copyright (c) 2017 Alessandro Rosa. All rights reserved.
//

import UIKit
import Update


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UpdateManager.askForUpdate()
    }

}
