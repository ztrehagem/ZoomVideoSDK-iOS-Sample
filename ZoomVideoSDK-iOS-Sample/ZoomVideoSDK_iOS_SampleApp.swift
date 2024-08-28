//
//  ZoomVideoSDK_iOS_SampleApp.swift
//  ZoomVideoSDK-iOS-Sample
//
//  Created by 諏訪 重貴 on 2024/08/26.
//

import SwiftUI
import ZoomVideoSDK

@main
struct ZoomVideoSDK_iOS_SampleApp: App {
    @StateObject private var room = Room()
    
    init() {
        initZoomVideoSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(room: room)
        }
    }
}

private func initZoomVideoSDK() {
    let initParams = ZoomVideoSDKInitParams()
    initParams.domain = "zoom.us"
    initParams.enableLog = true
    initParams.appGroupId = "group.dev.ztrehagem.ZoomVideoSDK-iOS-Sample"
    
    let sdkInitReturnStatus = ZoomVideoSDK.shareInstance()?.initialize(initParams)
    switch sdkInitReturnStatus {
    case .Errors_Success:
        print("SDK initialized successfully")
    default:
        if let error = sdkInitReturnStatus {
            print("SDK failed to initialize: \(error)")
        }
    }
}
