//
//  DCTargetType.swift
//  
//
//  Created by edy on 2021/7/31.
//

import UIKit
import Moya
import HandyJSON

public enum FZApiContentType: String, RawRepresentable {
    case json = "application/json;charset=utf-8"
    case urlEncoding = "application/x-www-form-urlencoded"
    case multipart = "multipart/form-data"
}

public enum FZMethodType: String, RawRepresentable {
    case get = "get"
    case post = "post"
    case put = "put"
    case delete = "delete"
}

public protocol FZApiProtocol {

    var baseUrlString: String { get }
    
    var path: String { get }
    ///网关,该字段会拼接在baseUrlString之后，path路径之前,如果不需要网管传""
    var gateWay: String { get }
    /// 修改请求方式，不直接使用Moya的
    var methodType: FZMethodType { get }
    ///请求头信息
    var headers: [String: String]? { get }
    
    var parameters: [String: Any] { get }
    
    var contentType: FZApiContentType { get }
    
    var multipartDatas: [FZMultiPartFormData] { get }
      
    var callBackQueue: DispatchQueue { get }
    
}
 
public extension FZApiProtocol {
     
    var baseUrlString: String {
        return FZApiConfig.serviceBaseURL ?? ""
    }
            
    var headers: [String: String]? {
        let headers: [String: String] = [:]
        return headers
    }
            
    var multipartDatas: [FZMultiPartFormData] {
        return []
    }
    
    var methodType: FZMethodType {
        return .post
    }

    var contentType: FZApiContentType {
        return .json
    }
    
    var parameters: [String: Any] {
        return [:]
    }
    
    var callBackQueue: DispatchQueue {
        return .main
    }
    
}

