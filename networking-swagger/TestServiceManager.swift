//
//
//  Networking-Swagger Code Generate Creater 1.0
//  TestServiceManager.swift
//  Copyright © 2019 OneFrame Mobile - Koçsistem All rights reserved.
//
 
import Foundation
import Networking
 
class TestManager {
    let manager : NetworkManager
    let config = NetworkConfig.shared
    let URL = "https://oneframe-configserver-api.apps-int.pcf.dev.kocsistem.com.tr/"
     
    let  RESULT_TAG = ["JSON_KEY"]
    let headerParamters : [String : String] = [
        "HEADER_PARAM":"HEADER_VALUE"
    ]
     
    init() {
        manager = NetworkManager()
        manager.setJsonKey(RESULT_TAG)
        config.deleteAllHeaders()
        config.setURL(URL:URL)
        // var _ = config.addHeader(parameters: headerParamters)
    }
 
    //{{request_func}}
}