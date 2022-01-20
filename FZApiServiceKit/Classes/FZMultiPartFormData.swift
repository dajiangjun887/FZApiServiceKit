//
//  DCMultiPartFormData.swift
//  
//
//  Created by edy on 2021/7/31.
//

import UIKit
import Moya

/// 上传 "multipart/form-data".
public struct FZMultiPartFormData {
    public enum FormDataProvider {
        case data(Foundation.Data)
        case file(URL)
        case stream(InputStream, UInt64)
    }
    
    public init(provider: FormDataProvider, name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.provider = provider
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    let provider: FormDataProvider
    
    let name: String
    
    let fileName: String?
    
    let mimeType: String?
    
    public static func convert(_ data: FZMultiPartFormData) -> Moya.MultipartFormData {
        var formDataProvider: Moya.MultipartFormData.FormDataProvider
        switch data.provider {
        case .data(let content):
            formDataProvider = .data(content)
        case .file(let url):
            formDataProvider = .file(url)
        case .stream(let stream, let number):
            formDataProvider = .stream(stream, number)
        }
        
        let formData = Moya.MultipartFormData(provider: formDataProvider,
                                              name: data.name,
                                              fileName: data.fileName,
                                              mimeType: data.mimeType)
        return formData
    }
}
