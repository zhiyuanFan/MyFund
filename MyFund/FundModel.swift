//
//  FundModel.swift
//  MyFund
//
//  Created by Jason Fan on 14/11/2017.
//  Copyright © 2017 QooApp. All rights reserved.
//

import Foundation
import ObjectMapper

class FundModel: Mappable {

    var fundcode : String?
    var name : String?
    var jzrq : String?
    var dwjz : String?
    var gsz : String?
    var gszzl : String?
    var gztime : String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        fundcode    <- map["fundcode"]
        name         <- map["name"]
        jzrq      <- map["jzrq"]
        dwjz       <- map["dwjz"]
        gsz  <- map["gsz"]
        gszzl  <- map["gszzl"]
        gztime     <- map["gztime"]
    }
}
