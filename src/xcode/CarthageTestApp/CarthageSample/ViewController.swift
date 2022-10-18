//
//  ViewController.swift
//  CarthageSample
//
//  Created by Ivan Nosar on 7/5/19.
//  Copyright © 2019 Ivan Nosar. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Alamofire.request("https://httpbin.org/get")
    }


}

