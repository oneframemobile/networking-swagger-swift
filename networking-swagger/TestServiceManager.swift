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
        // var _ = config.addHeader(parameters: headerParamters)
    }
 
    //{{request_func}}

public func findPetsByTags(tags: [String], success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/pet/findByTags?tags=\(tags)",success: success, fail: fail).fetch()
}

public func uploadFile(petId: Int, additionalMetadata: String, file: String, success: @escaping (ResultModel<ApiResponse>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: ["additionalMetadata" : "\(additionalMetadata)", "file" : "\(file)"], options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/pet/\(petId)/uploadImage",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func createUser(body: User, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/user",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func createUsersWithListInput(body: [User], success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/user/createWithList",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func logoutUser(success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/user/logout",success: success, fail: fail).fetch()
}

public func findPetsByStatus(status: [String], success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/pet/findByStatus?status=\(status)",success: success, fail: fail).fetch()
}

public func getUserByName(username: String, success:  @escaping (ResultModel<User>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/user/\(username)",success: success, fail: fail).fetch()
}

public func deleteUser(username: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        
        manager.delete("/user/\(username)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func updateUser(username: String, body: User, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.put("/user/\(username)",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func getOrderById(orderId: Int, success:  @escaping (ResultModel<Order>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/store/order/\(orderId)",success: success, fail: fail).fetch()
}

public func deleteOrder(orderId: Int, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        
        manager.delete("/store/order/\(orderId)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func loginUser(username: String, password: String, success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/user/login?username=\(username)&password=\(password)",success: success, fail: fail).fetch()
}

public func getInventory(success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/store/inventory",success: success, fail: fail).fetch()
}

public func addPet(body: Pet, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/pet",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func updatePet(body: Pet, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.put("/pet",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func getPetById(petId: Int, success:  @escaping (ResultModel<Pet>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/pet/\(petId)",success: success, fail: fail).fetch()
}

public func deletePet(petId: Int, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        
        manager.delete("/pet/\(petId)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func updatePetWithForm(petId: Int, name: String, status: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: ["name" : "\(name)", "status" : "\(status)"], options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/pet/\(petId)",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func placeOrder(body: Order, success: @escaping (ResultModel<Order>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/store/order",bodyParameters: jsonString, success: success, fail: fail).fetch()
}

public func createUsersWithArrayInput(body: [User], success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        manager.post("/user/createWithArray",bodyParameters: jsonString, success: success, fail: fail).fetch()
}
}