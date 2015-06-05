//
//  GlanceController.swift
//  MioDashboard-swift WatchKit Extension
//
//  Created by Safx Developer on 2015/05/17.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import WatchKit
import Foundation
import IIJMioKit

class GlanceController: WKInterfaceController {
    @IBOutlet weak var hddServiceCode: WKInterfaceLabel!
    @IBOutlet weak var couponTotal: WKInterfaceLabel!
    @IBOutlet weak var couponUsedToday: WKInterfaceLabel!
    @IBOutlet weak var additionalInfo: WKInterfaceLabel!
    private var lastUpdated: NSDate?

    var model: MIOCouponInfo_s! {
        didSet {
            let f = createByteCountFormatter()
            hddServiceCode.setText(model!.hddServiceCode)
            couponTotal.setText(f.stringFromByteCount(Int64(model!.totalCouponVolume) * 1000 * 1000))
            couponUsedToday.setText(f.stringFromByteCount(Int64(model!.couponUsedToday) * 1000 * 1000))
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        MIORestClient.sharedClient.setUp()

        restoreSavedInfo { m, date in
            if let f = m.first {
                self.model = f
                self.lastUpdated = date
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        if let d = lastUpdated where NSDate().timeIntervalSinceDate(d) < 300 {
            return
        }
        loadData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func loadData() {
        let client = MIORestClient.sharedClient

        if !client.authorized {
            let status = client.loadAccessToken()
            if status != .Success {
                additionalInfo.setText(status.rawValue)
                return
            }
        }

        client.getMergedInfo { [weak self] (response, error) -> Void in
            if let e = error {
                self?.additionalInfo.setText("Error: \(e.code) \(e.description)")
            } else if let r = response {
                if r.returnCode != "OK" {
                    self?.additionalInfo.setText(r.returnCode)
                } else {
                    if let s = self {
                        let m = r.couponInfo!.map{ MIOCouponInfo_s(info: $0) }
                        s.lastUpdated = NSDate()
                        saveInfo(m, s.lastUpdated!)
                        if let f = m.first {
                            s.additionalInfo.setText("")
                            s.model = f
                        } else {
                            s.additionalInfo.setText("No data")
                        }
                    }
                }
            } else {
                self?.additionalInfo.setText("No response")
            }
        }
    }
}
