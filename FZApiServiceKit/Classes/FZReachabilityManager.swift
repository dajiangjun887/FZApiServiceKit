//
//  DCReachabilityTool.swift
//  
//
//  Created by edy on 2021/7/30.
//

import UIKit
import Reachability

public class FZReachabilityManager {

    public static let shared = FZReachabilityManager()
    
    public var isConnect: Bool{
        get {
            return FZReachabilityManager.shared.reachability.connection != .unavailable
        }
    }

    var reachability: Reachability!
    public init() {
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to create Reachability")
            return
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Notifier")
            return
        }
    }
    
    deinit {
        
    }

}
