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
            let u = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
            return cal.components(u, fromDate: a) == cal.components(u, fromDate: b)
        }

        return reduce(packetLog, 0) { a1, e1 in
            return a1 + (sameDay(e1.date, NSDate()) ? e1.withCoupon : 0)
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
        return reduce(coupon, 0) { a, e in return a + e.volume }
    }
    var couponUsedToday: UInt {
        return reduce(hdoInfo, 0) { $0 + $1.couponUsedToday }
    }
}

extension MIORestClient {
    func setUp() {
        setUp("Your_Client_ID", redirectURI: "Your_Redirect_URI", state: "Some_State")
    }
}