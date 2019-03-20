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
    let URL = "http://petstore.swagger.io/v2/swagger.json/"
     
    let  RESULT_TAG = ["JSON_KEY"]
    let headerParamters : [String : String] = [
        "HEADER_PARAM":"HEADER_VALUE"
    ]
     
    init() {
        manager = NetworkManager()
        manager.setJsonKey(RESULT_TAG)
        config.deleteAllHeaders()
        config.setURL(URL:URL)
        var _ = config.addHeader(parameters: headerParamters)
    }
 
    //{{request_func}}

public func findPetsByTags(tags : [String],success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /pet/findByTags queryFormula : ?tags= \(tags) pathFormula : ,success: success, fail: fail).fetch()
}

public func logoutUser(,success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /user/logout queryFormula :  pathFormula : ,success: success, fail: fail).fetch()
}

public func findPetsByStatus(status : [String],success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /pet/findByStatus queryFormula : pet?status= \(status) pathFormula : ,success: success, fail: fail).fetch()
}

public func getUserByName(username : String,success:  @escaping (ResultModel<User>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /user/{username} queryFormula :  pathFormula : "/user/" + username,success: success, fail: fail).fetch()
}

public func getOrderById(orderId : Int,success:  @escaping (ResultModel<Order>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /store/order/{orderId} queryFormula :  pathFormula : "/store/order/" + orderId,success: success, fail: fail).fetch()
}

public func loginUser(password : String,success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /user/login queryFormula : user?password= \(password) pathFormula : ,success: success, fail: fail).fetch()
}

public func getInventory(,success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /store/inventory queryFormula :  pathFormula : ,success: success, fail: fail).fetch()
}

public func getPetById(petId : Int,success:  @escaping (ResultModel<Pet>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get(path : /pet/{petId} queryFormula :  pathFormula : "/pet/" + petId,success: success, fail: fail).fetch()
}
}