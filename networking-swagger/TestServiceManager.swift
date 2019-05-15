//
//
//  Networking-Swagger Code Generate Creater 1.0
//  testServiceManager.swift
//  Copyright © 2019 OneFrame Mobile - Koçsistem All rights reserved.
//
 
import Foundation
import Networking
 
class testManager {
    let manager : NetworkManager
    let config = NetworkConfig.shared
    let URL = "/Users/a02484320/Desktop/oneframeapi.json/"
     
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

public func Get(PageSize: Int, PageIndex: Int, success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/users?PageSize=\(PageSize)&PageIndex=\(PageIndex)",success: success, fail: fail).fetch()
}

public func Post(user: UserPostRequest, success: @escaping (ResultModel<ApplicationUser>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/users",bodyParameters: user, success: success, fail: fail).fetch()
}

public func Search(Username: String, PageSize: Int, PageIndex: Int, success:  @escaping (ResultModel<ApplicationUser>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/users/search?Username=\(Username)&PageSize=\(PageSize)&PageIndex=\(PageIndex)",success: success, fail: fail).fetch()
}

public func ForgotPassword(model: ForgotPasswordRequest, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/users/forgotpassword",bodyParameters: model, success: success, fail: fail).fetch()
}

public func GetClaimsInRole(roleName: String, success:  @escaping (ResultModel<ClaimResponse>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/roles/\(roleName)/claims",success: success, fail: fail).fetch()
}

public func AddClaimToRole(roleName: String, model: RoleClaimPostRequest, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/roles/\(roleName)/claims",bodyParameters: model, success: success, fail: fail).fetch()
}

public func GetUsersInRole(roleName: String, success:  @escaping (ResultModel<RoleUserResponse>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/roles/\(roleName)/users",success: success, fail: fail).fetch()
}

public func Get(success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/roles",success: success, fail: fail).fetch()
}

public func Post(role: RolePostRequest, success: @escaping (ResultModel<ApplicationRole>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/roles",bodyParameters: role, success: success, fail: fail).fetch()
}

public func Get(success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/menu",success: success, fail: fail).fetch()
}

public func Register(model: UserPostRequest, success: @escaping (ResultModel<LoginResponse>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/users/register",bodyParameters: model, success: success, fail: fail).fetch()
}

public func RemoveUserFromRole(roleName: String, username: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/roles/\(roleName)/users/\(username)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func AddUserToRole(roleName: String, username: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/roles/\(roleName)/users/\(username)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func roleget(roleName: String, success:  @escaping (ResultModel<ApplicationRole>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/roles/\(roleName)",success: success, fail: fail).fetch()
}

public func Delete(roleName: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/roles/\(roleName)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func Patch(roleName: String, role: RolePatchRequest, success: @escaping (ResultModel<ApplicationRole>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/roles/\(roleName)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func RemoveClaimFromRole(roleName: String, claimvalue: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/roles/\(roleName)/claims/\(claimvalue)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func ResetPassword(model: ResetPasswordRequest, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/users/resetpassword",bodyParameters: model, success: success, fail: fail).fetch()
}

public func Login(model: LoginRequest, success: @escaping (ResultModel<LoginResponse>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/users/login",bodyParameters: model, success: success, fail: fail).fetch()
}

public func UserGet(username: String, success:  @escaping (ResultModel<ApplicationUser>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/users/\(username)",success: success, fail: fail).fetch()
}

public func Delete(username: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/users/\(username)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func Patch(username: String, user: UserPatchRequest, success: @escaping (ResultModel<ApplicationUser>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/users/\(username)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func RemoveClaimFromUser(username: String, claimvalue: String, success: @escaping (ResultModel<String>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.delete("/users/\(username)/claims/\(claimvalue)",bodyParameters: "", success: success, fail: fail).fetch()
}

public func GetClaimsInUser(username: String, success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/users/\(username)/claims",success: success, fail: fail).fetch()
}

public func AddClaimToUser(username: String, model: UserClaimPostRequest, success: @escaping (ResultModel<UserClaimPostRequest>) -> (),
    fail: @escaping (ErrorModel) -> Void ) {
        manager.post("/users/\(username)/claims",bodyParameters: model, success: success, fail: fail).fetch()
}

public func Index(success:  @escaping (ResultModel<String>) -> Void,
    fail:  @escaping (ErrorModel) -> Void) {
    manager.get("/install",success: success, fail: fail).fetch()
}
}