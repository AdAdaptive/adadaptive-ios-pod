//
//  AdAdaptiveConfig.swift
//  AdAdaptiveSDK
//
/**************************************************************************************************************************
 *
 * SystemicsCode Nordic AB
 *
 **************************************************************************************************************************/

import Foundation

struct AD_PLATFORM {
    let BASE        :String
    let AD          :String
    let BEACON      :String
    let CAMPAIGN    :String
    let SDK_VER     :String = "V.1.1.0"
}

extension AD_PLATFORM {
    init() {            //default intializer
        self.BASE       = "https://www.advertisement.cloud/api/v1.0"
        self.AD         = BASE + "/ads"
        self.BEACON     = BASE + "/beacons"
        self.CAMPAIGN   = BASE + "/ads/campaign"
    }
    init(BASE: String){ //intializer for private ad platforms
        self.BASE       = BASE
        self.AD         = BASE + "/ads"
        self.BEACON     = BASE + "/beacons"
        self.CAMPAIGN   = BASE + "/ads/campaign"
    }
}
