//
//  Chirp.swift
//  PayPal
//
//  Created by Joe Todd on 28/06/2018.
//  Copyright © 2018 Chirp. All rights reserved.
//

import ChirpSDK

protocol ChirpDelegate {
    func onReceived(data: Data?)
    func onSent(data: Data?)
}


class ChirpService {
    var delegate: ChirpDelegate?
    var sdk: ChirpSDK?

    public init() {
        sdk = ChirpSDK(appKey: CHIRP_APP_KEY, andSecret: CHIRP_APP_SECRET)
        if let sdk = sdk {
            sdk.setConfig(CHIRP_APP_CONFIG)
            sdk.start()

            sdk.receivedBlock = {
                (data: Data?, channel: UInt?) -> () in
                if let delegate = self.delegate {
                    delegate.onReceived(data: data)
                }
                return;
            }

            sdk.sentBlock = {
                (data: Data?, channel: UInt?) -> () in
                if let delegate = self.delegate {
                    delegate.onSent(data: data)
                }
                return;
            }
        }
    }

    func send(payload: Data) {
        if let sdk = sdk {
            sdk.send(payload)
        }
    }
    func start() {
        if let sdk = sdk {
            sdk.start()
        }
    }
    func stop() {
        if let sdk = sdk {
            sdk.stop()
        }
    }
}
