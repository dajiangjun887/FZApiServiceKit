//
//  FZApiProtcolTarget.swift
//
//
//  Created by edy on 2021/9/8.
//

import UIKit
import Moya

struct FZApiProtcolTarget: TargetType {

    private let _baseUrl: String
    
    private let _path: String
        
    private let _method: FZMethodType
    
    private let _parameters: [String: Any]
    
    private let _contentType: FZApiContentType
    
    private let _multipartDatas: [FZMultiPartFormData]?
    
    private let _headers: [String: String]?
    
    init(baseUrl: String, path: String, method: FZMethodType, parameters: [String: Any], contentType: FZApiContentType, multipartDatas: [FZMultiPartFormData]? = nil, headers: [String: String]? = nil) {
        _baseUrl = baseUrl
        _path = path
        _method = method
        _parameters = parameters
        _contentType = contentType
        _multipartDatas = multipartDatas
        _headers = headers
    }

    var baseURL: URL {
        return URL(string: _baseUrl) ?? URL(fileURLWithPath: "")
    }
    
    var path: String {
        return _path
    }
    
    var method: Moya.Method {
        switch _method {
        case .post:
            return .post
        case .get:
            return .get
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var sampleData: Data {
        guard let data = "{}".data(using: .utf8) else {
            return Data()
        }
        return data
    }
    
    var task: Task {
        ///设置默认参数
        let paras = _parameters
        switch _contentType  {
        case .urlEncoding:
            return .requestParameters(parameters: paras, encoding: URLEncoding.queryString)
        case .json:
            return .requestParameters(parameters: paras, encoding: JSONEncoding.default)
        case .multipart:
            guard let multipartDatas = _multipartDatas else {
                fatalError("multipartDatas不能为空")
            }
            let formDatas = multipartDatas.map({ FZMultiPartFormData.convert($0) })
            return .uploadCompositeMultipart(formDatas, urlParameters: paras)
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        if let _headers = _headers {
            headers = _headers
        }
        switch _contentType {
        case .json:
            headers["Content-Type"] = "application/json"
        case .urlEncoding:
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        case .multipart:
            headers["Content-Type"] = "multipart/form-data"
        }
        return headers
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
