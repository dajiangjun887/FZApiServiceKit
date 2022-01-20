//
//  FZNetConfig.swift
//  
//
//  Created by edy on 2021/8/3.
//

import UIKit

public class FZApiConfig {

    ///是否需要api调试信息
    public static var needApiDebugInfo = true
    ///默认baseurl
    public static var serviceBaseURL : String?
   ///默认请求头
    public static var defaultHeaders: [String: String] = [:]
    ///默认参数
    public static var defaultParams: [String: Any] = [:]
    ///业务成功码
    public static var successCodes: [Int] = [200]
    ///数据转模型默认解析路径（默认从哪个字段开始解析）
    public static var defaultDesinatedPath = "data"
    
    /// 统一处理的业务码，一旦设置，发生这种业务，将不再执行正常的成功失败回调，会调用这个闭包
    /// 比如可以做统一需要登录的处理等
    /// - Parameters:
    ///   - codes: 统一处理的业务码
    ///   - handleBlock: 执行的回调
    public static func setBusinessCodes(codes: [Int], handleBlock: @escaping (Int, String?, FZServiceError?) -> ()) {
        businessCodes = codes
        businessHandleBlock = handleBlock
    }
    
    static var businessCodes: [Int] = []
    
    static var businessHandleBlock: ((Int, String?, FZServiceError?) -> ())?

}
