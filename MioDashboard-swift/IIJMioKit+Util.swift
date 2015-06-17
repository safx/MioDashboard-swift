//
//  IIJMioKit+Util.swift
//  MioDashboard-swift
//
//  Created by Safx Developer on 2015/05/23.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation
import IIJMioKit

extension MIOCouponHdoInfo {
    var couponUsedToday: UInt {
        func sameDay(a: NSDate, b: NSDate) -> Bool {
            let cal = NSCalendar.currentCalendar()
            let u: NSCalendarUnit = [.Year, .Month, .Day]
            return cal.components(u, fromDate: a) == cal.components(u, fromDate: b)
        }

        return packetLog.reduce(0) { a1, e1 in
            return a1 + (sameDay(e1.date, b: NSDate()) ? e1.withCoupon : 0)
        }
    }
    var phoneNumber: String {
        let x = number.startIndex
        let y = advance(x, 3)
        let z = advance(y, 4)
        let a = number.substringWithRange(Range<String.Index>(start: x, end: y))
        let b = number.substringWithRange(Range<String.Index>(start: y, end: z))
        let c = number.substringFromIndex(z)
        return "\(a)-\(b)-\(c)"
    }
}

extension MIOCouponInfo {
    var totalCouponVolume: UInt {
        return coupon.reduce(0) { a, e in return a + e.volume }
    }
    var couponUsedToday: UInt {
        return hdoInfo.reduce(0) { $0 + $1.couponUsedToday }
    }
}

extension MIORestClient {
    func setUp() {
        setUp("nq0ehnd2JxFVgvu1DTk", redirectURI: "http://safx-dev.blogspot.jp/iijmio/", state: "Some_State")
    }
}
