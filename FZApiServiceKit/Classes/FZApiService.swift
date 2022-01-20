//
//  DCNet.swift
//  
//
//  Created by edy on 2021/7/31.
//

import UIKit
import HandyJSON
import Moya

public class FZApiService: NSObject {
    
    public typealias SuccessCallBack = ((String) -> Void)
    public typealias FailureCallBack = ((FZServiceError) -> Void)
        
    public static func sendObjectRequest<T: HandyJSON>(apiProtocol: FZApiProtocol, modelType: T.Type ,desinatedPath: String? = FZApiConfig.defaultDesinatedPath, loading: Bool = false, successCallBack: @escaping ((T?) -> ()), failureCallBack: @escaping FailureCallBack) {
        
        sendRequest(apiProtocol: apiProtocol, loading: loading, successCallBack: { json in
            let model = T.deserialize(from: json,designatedPath: desinatedPath)
            successCallBack(model)
        }, failureCallBack: failureCallBack)
    }
    
    public static func sendArrayRequest<T: HandyJSON>(apiProtocol: FZApiProtocol, modelType: T.Type, desinatedPath: String? = FZApiConfig.defaultDesinatedPath, loading: Bool = false, successCallBack: @escaping (([T]) -> ()), failureCallBack: @escaping FailureCallBack) {
        
        sendRequest(apiProtocol: apiProtocol, loading: loading, successCallBack: { json in
            let models = [T].deserialize(from: json, designatedPath: desinatedPath)?.compactMap({ $0 }) ?? []
            successCallBack(models)
        }, failureCallBack: failureCallBack)
    }
    
    public static func sendRequest(apiProtocol: FZApiProtocol, loading: Bool = false,successCallBack: @escaping SuccessCallBack, failureCallBack: @escaping FailureCallBack) {
        
        if FZReachabilityManager.shared.isConnect == false {
            DispatchQueue.main.async {
//                DCToastTool.showError("网络不可用，请检查下您的网络")
                let code = 100
                let error = FZServiceError(code: "\(100)", reason: "网络不可用，请检查下您的网络", api: apiProtocol.path)
                if FZApiConfig.businessCodes.contains(code) {
                    FZApiConfig.businessHandleBlock?(code,nil,error)
                } else {
                    failureCallBack(error)
                }
            }
            return
        }
        let paras = apiProtocol.parameters + FZApiConfig.defaultParams
        let headers = (apiProtocol.headers ?? [:]) + FZApiConfig.defaultHeaders
        let t_path = apiProtocol.gateWay + apiProtocol.path
        let target = FZApiProtcolTarget(baseUrl: apiProtocol.baseUrlString, path: t_path, method: apiProtocol.methodType, parameters: paras, contentType: apiProtocol.contentType,headers: headers)
        
        let provider = FZApiService.getProviderByTarget(target: target)
        let m_target = MultiTarget(target)
        ///获取调试信息
        var logInfo = "\n apiPath = \n"  + apiProtocol.baseUrlString + t_path + "\n headers = \n \(headers)" + "\n params = \n \(paras)"
        provider.request(m_target, callbackQueue: apiProtocol.callBackQueue) { result in
            switch result {
            case .success(let response):
                
                let jsonStr = String(data: response.data, encoding: .utf8) ?? ""
                logInfo += "\n responseString = \(jsonStr)"
                
                let dict = JSONSerialization.getDictionaryFromJSONData(jsonData: response.data) ?? [:]
                guard let code = dict["code"] as? String else {
                    dePrint("code解析失败")
                    return
                }
                guard let code = Int(code) else {
                    dePrint("code转Int失败")
                    return
                }
                ///先做需要统一处理的业务判断
                if FZApiConfig.businessCodes.contains(code) {
                    FZApiConfig.businessHandleBlock?(code, jsonStr, nil)
                } else if FZApiConfig.successCodes.contains(code) {
                    successCallBack(jsonStr)
                } else {
                    let message = dict["msg"] as? String
                    let service_error = FZServiceError(code: "\(code)", reason: message ?? "", api: target.path)
                    failureCallBack(service_error)
                }
            case .failure(let error):
                
                logInfo += "\n error = \(error)"
                let service_error = FZServiceError(code: "\(error.errorCode)", reason: error.errorDescription ?? "", api: target.path)
                if FZApiConfig.businessCodes.contains(error.errorCode) {
                    FZApiConfig.businessHandleBlock?(error.errorCode, nil, service_error)
                } else {
                    failureCallBack(service_error)
                }
            }
            ///判断是否需要log信息
            if FZApiConfig.needApiDebugInfo {
                ///打印接口调试信息
                dePrint(logInfo)
            }
        }
    }
    
    static func getProviderByTarget(target: TargetType, loading: Bool = false) -> MoyaProvider<MultiTarget> {
        let provider = MoyaProvider<MultiTarget>(endpointClosure: { (target: MultiTarget) -> Endpoint in     // 设置header
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString
            let headers: [String: String] = target.headers ?? [:]
            let endpoint = Endpoint(url: url, sampleResponseClosure: { () -> EndpointSampleResponse in
                .networkResponse(200, target.sampleData)
            }, method: target.method, task: target.task, httpHeaderFields: headers)
            return endpoint
        }, requestClosure: { (point: Endpoint, closure: MoyaProvider<MultiTarget>.RequestResultClosure) in
            do {
                var request = try point.urlRequest()
                request.timeoutInterval = 30
                closure(.success(request))
            } catch {
                closure(.failure(MoyaError.requestMapping(point.url)))
            }
        }, stubClosure: { (target: MultiTarget) -> StubBehavior in
            return .never
        }, callbackQueue: DispatchQueue.main,
        plugins: [NetworkActivityPlugin { (type, target) in
            switch type{
            case .began:
                DispatchQueue.main.async {
                    if loading{
//                        DCToastTool.showLoading()
                    }
                }
            case .ended:
                if loading {
//                    DCToastTool.hideLoading()
                }
            }
        }])
        return provider
    }    
}


extension JSONSerialization {
   
    static func getDictionaryFromJSONData(jsonData: Data) -> [String: Any]? {
         var dict: [String: Any]?
         do {
             dict = try JSONSerialization.jsonObject(with:jsonData,options: .mutableContainers) as? [String : Any]
         } catch {
             
         }
         return dict
     }

}

public extension Dictionary {

    /// : Merge the keys/values of two dictionaries.
    ///
    ///        let dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        let result = dict + dict2
    ///        result["key1"] -> "value1"
    ///        result["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - rhs: dictionary
    /// - Returns: An dictionary with keys and values from both.
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }

}

func dePrint<T>(_ message: T, filePath: String = #file, rowCount: Int = #line) {
    #if DEBUG
    let fileName = (filePath as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
    print(fileName + "/" + "\(rowCount)" + " \(message)" + "\n")
    #endif
}
