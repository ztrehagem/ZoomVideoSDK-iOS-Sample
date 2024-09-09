//
//  Room.swift
//  ZoomVideoSDK-iOS-Sample
//
//  Created by 諏訪 重貴 on 2024/08/26.
//

import Foundation
import ZoomVideoSDK

class Room: NSObject, ObservableObject {
    @Published var state: State = .leaved
    @Published var users: [ZoomVideoSDKUser] = []
    
    override init() {
        super.init()
        ZoomVideoSDK.shareInstance()?.delegate = self
    }
    
    func joinSession() {
        state = .joining
        
        let sessionContext = ZoomVideoSDKSessionContext()
        // Ensure that you do not hard code JWT or any other confidential credentials in your production app.
        sessionContext.token = "JWT"
        sessionContext.sessionName = "session"
        sessionContext.userName = "name"
        
        let videoOptions = ZoomVideoSDKVideoOptions()
        videoOptions.localVideoOn = true
        sessionContext.videoOption = videoOptions
        
        guard let session = ZoomVideoSDK.shareInstance()?.joinSession(sessionContext) else {
            state = .leaved
            return
        }
        // Session joined successfully.
    }
    
    func leaveSession() {
        // A value of true will end the session if you are the host
        ZoomVideoSDK.shareInstance()?.leaveSession(false)
    }
}

extension Room {
    enum State {
        case leaved, joining, joined
    }
}

extension Room: ZoomVideoSDKDelegate {
    func onError(_ ErrorType: ZoomVideoSDKError, detail details: Int) {
        print("ZoomVideoSDKDelegate.onError")
        
        switch ErrorType {
        case .Errors_Success:
            // Your ZoomVideoSDK operation was successful.
            print("Success")
            default:
            // Your ZoomVideoSDK operation raised an error.
            // Refer to error code documentation.
            print("Error \(ErrorType) \(details)")
            return
        }
    }
    
    func onSessionJoin() {
        print("ZoomVideoSDKDelegate.onSessionJoin")
        state = .joined
        if let mySelf = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            users.append(mySelf)
        }
    }
    
    func onSessionLeave(_ reason: ZoomVideoSDKSessionLeaveReason) {
        print("ZoomVideoSDKDelegate.onSessionLeave")
        users.removeAll()
        state = .leaved
    }
    
    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        print("ZoomVideoSDKDelegate.onUserJoin")
        if let userArray {
            users.append(contentsOf: userArray)
        }
    }
    
    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        print("ZoomVideoSDKDelegate.onUserLeave")
        if let userArray {
            users.removeAll(where: { user in
                userArray.contains(where: { leavedUser in
                    user.getID() == leavedUser.getID()
                })
            })
        }
    }
    
    func onUserShareStatusChanged(_ helper: ZoomVideoSDKShareHelper?, user: ZoomVideoSDKUser?, status: ZoomVideoSDKReceiveSharingStatus) {
        print("ZoomVideoSDKDelegate.onUserShareStatusChanged \(status)")
    }
}
