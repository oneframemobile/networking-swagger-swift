//
// ClaimsIdentity.swift
//
// Generated by oneframemobile
// https://github.com/oneframemobile/networking-swagger-swift
//

import Networking
import Foundation


public struct ClaimsIdentity: Serializable {

    public var authenticationType: String?
    public var isAuthenticated: Bool?
    public var actor: ClaimsIdentity?
    public var bootstrapContext: Any?
    public var claims: [Claim]?
    public var label: String?
    public var name: String?
    public var nameClaimType: String?
    public var roleClaimType: String?

    public init(authenticationType: String?, isAuthenticated: Bool?, actor: ClaimsIdentity?, bootstrapContext: Any?, claims: [Claim]?, label: String?, name: String?, nameClaimType: String?, roleClaimType: String?) {
        self.authenticationType = authenticationType
        self.isAuthenticated = isAuthenticated
        self.actor = actor
        self.bootstrapContext = bootstrapContext
        self.claims = claims
        self.label = label
        self.name = name
        self.nameClaimType = nameClaimType
        self.roleClaimType = roleClaimType
    }


}

