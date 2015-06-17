//
//  InterfaceController.swift
//  MioDashboard-swift WatchKit Extension
//
//  Created by Safx Developer on 2015/05/17.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import WatchKit
import Foundation
import IIJMioKit


class TableRow : NSObject {
    @IBOutlet weak var hddServiceCode: WKInterfaceLabel!
    @IBOutlet weak var couponTotal: WKInterfaceLabel!
    @IBOutlet weak var couponUsedToday: WKInterfaceLabel!

    var model: MIOCouponInfo_s! {
        didSet {
            let f = createByteCountFormatter()
            hddServiceCode.setText(model!.hddServiceCode)
            couponTotal.setText(f.stringFromByteCount(Int64(model!.totalCouponVolume) * 1000 * 1000))
            couponUsedToday.setText(f.stringFromByteCount(Int64(model!.couponUsedToday) * 1000 * 1000))
        }
    }
}

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var additionalInfo: WKInterfaceLabel!
    private var model: [MIOCouponInfo_s] = []
    private var lastUpdated: NSDate?


    override func awakeWithContext(context: AnyObject?) {
        MIORestClient.sharedClient.setUp()
        super.awakeWithContext(context)

        restoreSavedInfo { m, date in
            self.model = m
            self.lastUpdated = date
            self.setTableData(model)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        if let d = lastUpdated where NSDate().timeIntervalSinceDate(d) < 300 {
            return
        }
        loadTableData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
            precondition(segueIdentifier == "detail")
        return rowIndex < model.count ? self.model[rowIndex] : nil
    }

    private func loadTableData() {
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
                        s.setTableData(m)
                        s.additionalInfo.setText("")
                        s.lastUpdated = NSDate()
                        saveInfo(m, lastUpdated: s.lastUpdated!)
                    }
                }
            } else {
                self?.additionalInfo.setText("No response")
            }
        }
    }

    private func setTableData(cs: [MIOCouponInfo_s]) {
        if cs.isEmpty {
            self.additionalInfo.setText("No data")
            return
        }

        table.setNumberOfRows(cs.count, withRowType: "default")

        for (i, c) in cs.enumerate() {
            if let row = table.rowControllerAtIndex(i) as? TableRow {
                row.model = c
            }
        }
        model = cs
    }

    // TODO: use other RowType
    private func setErrorData(reason: String) {
        table.setNumberOfRows(1, withRowType: "default")
        if let row = table.rowControllerAtIndex(0) as? TableRow {
            row.hddServiceCode.setText(reason)
            row.couponTotal.setText("Error")
            row.couponUsedToday.setText("")
        }
    }

    // TODO: use other RowType
    private func setErrorData(reason: NSError) {
        table.setNumberOfRows(1, withRowType: "default")
        if let row = table.rowControllerAtIndex(0) as? TableRow {
            row.hddServiceCode.setText("\(reason.domain)")
            row.couponTotal.setText("\(reason.code)")
            row.couponUsedToday.setText("\(reason.description)")
        }
    }
}

class DetailTableRow : NSObject {
    @IBOutlet weak var number: WKInterfaceLabel!
    @IBOutlet weak var couponUsedToday: WKInterfaceLabel!

    var model: MIOCouponHdoInfo_s! {
        didSet {
            let f = createByteCountFormatter()
            number.setText(model!.phoneNumber)
            couponUsedToday.setText(f.stringFromByteCount(Int64(model!.couponUsedToday) * 1000 * 1000))
        }
    }
}

class DetailInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        if let m = context as? MIOCouponInfo_s {
            setTableData(m)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func setTableData(model: MIOCouponInfo_s) {
        let cs = model.hdoInfo
        table.setNumberOfRows(cs.count, withRowType: "default")

        for (i, c) in cs.enumerate() {
            if let row = table.rowControllerAtIndex(i) as? DetailTableRow {
                row.model = c
            }
        }
    }
}
