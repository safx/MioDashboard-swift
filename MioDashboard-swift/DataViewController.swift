//
//  DataViewController.swift
//  MioDashboard-swift
//
//  Created by Safx Developer on 2015/05/17.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit


class DataViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    var model: MIOCouponInfo?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let m = model {
            dataLabel!.text = m.hddServiceCode
        } else {
            dataLabel!.text = ""
        }
    }


}

