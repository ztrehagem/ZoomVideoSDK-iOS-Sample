//
//  SampleHandler.swift
//  ScreenShare
//
//  Created by 諏訪 重貴 on 2024/08/27.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler, ZoomVideoSDKScreenShareServiceDelegate {
    var screenShareService: ZoomVideoSDKScreenShareService?
    
    override init() {
        print("SampleHandler init")
        super.init()
        // Create an instance of ZoomVideoSDKScreenShareService to handle broadcast actions.
        let params = ZoomVideoSDKScreenShareServiceInitParams()
        // Provide your app group ID from your Apple Developer account.
        params.appGroupId = "group.dev.ztrehagem.ZoomVideoSDK-iOS-Sample"
        // Set this to true to enable sharing device audio during screenshare
        params.isWithDeviceAudio = true
        let service = ZoomVideoSDKScreenShareService(params: params)
        self.screenShareService = service
        screenShareService?.delegate = self
    }
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print("SampleHandler broadcastStarted")
        guard let setupInfo = setupInfo else { return }
        // Pass setup info to SDK.
        screenShareService?.broadcastStarted(withSetupInfo: setupInfo)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print("SampleHandler broadcastPaused")
        // Notify SDK the broadcast was paused.
        screenShareService?.broadcastPaused()
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print("SampleHandler broadcastResumed")
        // Notify SDK the broadcast was resumed.
        screenShareService?.broadcastResumed()
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        print("SampleHandler broadcastFinished")
        // Notify SDK the broadcast has finished.
        screenShareService?.broadcastFinished()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        // Pass sample bugger into SDK.
        screenShareService?.processSampleBuffer(sampleBuffer, with: sampleBufferType)
    }
    
    func zoomVideoSDKScreenShareServiceFinishBroadcastWithError(_ error: Error?) {
        print("SampleHandler zoomVideoSDKScreenShareServiceFinishBroadcastWithError")
        guard let error = error else { return }
        // Terminate broadcast when notified of error from SDK.
        finishBroadcastWithError(error)
    }
}
