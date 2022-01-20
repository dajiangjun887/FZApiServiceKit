//
//  DCError.swift
//  
//
//  Created by edy on 2021/7/31.
//

import UIKit
import HandyJSON

///整个项目使用一个error类型，不同的error用不同的错误码
public class FZServiceError: LocalizedError, CustomStringConvertible {

    public var code = ""
    
    public var reason = ""
    
    public var api: String?
    
    public init(code: String, reason: String, api: String? = nil) {
        self.code = code
        self.reason = reason
        self.api = api
    }
    
    public var description: String {
        var desc: String!
        if let api = api {
            desc = "api = \(api)\n errorCode = \(code)\n errorReason = \(reason)"
        } else {
            desc = "errorCode = \(code)\n errorReason = \(reason)"
        }
        return desc
    }
    
    public var errorDescription: String? {
        return reason
    }
}

