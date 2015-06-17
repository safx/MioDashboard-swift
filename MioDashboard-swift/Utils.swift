//
//  Utils.swift
//  MioDashboard-swift
//
//  Created by Safx Developer on 2015/05/23.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import IIJMioKit

func createByteCountFormatter() -> NSByteCountFormatter {
    let f = NSByteCountFormatter()
    f.allowsNonnumericFormatting = false
    f.allowedUnits = [.UseMB, .UseGB]
    return f
}

@objc
class MIOCouponInfo_s: NSObject, NSCoding {
    let hddServiceCode: String
    let totalCouponVolume: Int64
    let hdoInfo: [MIOCouponHdoInfo_s]

    init(info: MIOCouponInfo) {
        self.hddServiceCode = info.hddServiceCode
        self.totalCouponVolume = Int64(info.totalCouponVolume)
        self.hdoInfo = info.hdoInfo.map { MIOCouponHdoInfo_s(info: $0) }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(hddServiceCode, forKey: "hddServiceCode")
        aCoder.encodeInt64(totalCouponVolume, forKey: "totalCouponVolume")
        aCoder.encodeObject(hdoInfo as NSArray, forKey: "hdoInfo")
    }

    required init?(coder aDecoder: NSCoder) {
        self.hddServiceCode = aDecoder.decodeObjectForKey("hddServiceCode") as? String ?? ""
        self.totalCouponVolume = aDecoder.decodeInt64ForKey("totalCouponVolume")
        self.hdoInfo = aDecoder.decodeObjectForKey("hdoInfo") as? [MIOCouponHdoInfo_s] ?? []
    }

    var couponUsedToday: UInt {
        return UInt(hdoInfo.reduce(0) { $0 + $1.couponUsedToday })
    }
}

@objc
class MIOCouponHdoInfo_s: NSObject, NSCoding {
    let phoneNumber: String
    let couponUsedToday: Int64

    init(info: MIOCouponHdoInfo) {
        self.phoneNumber = info.phoneNumber
        self.couponUsedToday = Int64(info.couponUsedToday)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(phoneNumber, forKey: "phoneNumber")
        aCoder.encodeInt64(couponUsedToday, forKey: "couponUsedToday")
    }

    required init?(coder aDecoder: NSCoder) {
        self.phoneNumber = aDecoder.decodeObjectForKey("phoneNumber") as! String
        self.couponUsedToday = aDecoder.decodeInt64ForKey("couponUsedToday")
    }
}

func restoreSavedInfo(@noescape completion: ([MIOCouponInfo_s], NSDate) -> ()) {
    if let sharedDefaults = NSUserDefaults(suiteName: "group.com.blogspot.safxdev.miodashboard") {
        if let data = sharedDefaults.objectForKey("model") as? NSData {
            if let model = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                let lastUpdated = sharedDefaults.objectForKey("lastUpdated") as? NSDate ?? NSDate(timeIntervalSince1970: 0)
                completion(model as! [MIOCouponInfo_s], lastUpdated)
            }
        }
    }
}

func saveInfo(model: [MIOCouponInfo_s], lastUpdated: NSDate) {
    if let sharedDefaults = NSUserDefaults(suiteName: "group.com.blogspot.safxdev.miodashboard") {
        let data = NSKeyedArchiver.archivedDataWithRootObject(model)
        sharedDefaults.setObject(data, forKey: "model")
        sharedDefaults.setObject(lastUpdated, forKey: "lastUpdated")
    }
}
