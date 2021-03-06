//
// Claim.swift
//
// Generated by oneframemobile
// https://github.com/oneframemobile/networking-swagger-swift
//

import Networking
import Foundation


public struct Claim: Serializable {

    public var issuer: String?
    public var originalIssuer: String?
    public var properties: [String:String]?
    public var subject: ClaimsIdentity?
    public var type: String?
    public var value: String?
    public var valueType: String?

    public init(issuer: String?, originalIssuer: String?, properties: [String:String]?, subject: ClaimsIdentity?, type: String?, value: String?, valueType: String?) {
        self.issuer = issuer
        self.originalIssuer = originalIssuer
        self.properties = properties
        self.subject = subject
        self.type = type
        self.value = value
        self.valueType = valueType
    }


}

