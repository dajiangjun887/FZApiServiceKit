//
//  DCBaseModel.swift
//  
//
//  Created by edy on 2021/8/1.
//

import UIKit
import HandyJSON
import Moya

public class FZBaseModel: HandyJSON {
   
    var code  = ""
   
    var message = ""
   
    var data : Any?
   
    required public init() {}
}

public extension FZBaseModel {
   
    var generalCode: String {
        return code
    }
    
    var generalMessage: String {
        return message
    }
}

