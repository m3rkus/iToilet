//
//  StatusMQTTService.swift
//  iToilet
//
//  Created by Roman Anistratenko on 11.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Foundation
import SwiftMQTT
import Repeat

protocol StatusMQTTServiceDelegate: class {
    
    func updateStatus(isToiletAvailable: Bool)
}

final class StatusMQTTService {

    weak var delegate: StatusMQTTServiceDelegate?
    
    private let username = "miha25255"
    private let host = "mqtt.thingspeak.com"
    private let port: UInt16 = 1883
    private let mqttApiKey = "FVRIJXU8MB0L8K5U"
    private let responseFormat = "json"
    private var isDisconnectInitiatedByApp = false
    private var reconnectionTimer: Repeater?
    private var reconnectionTimeInterval: Double = 0
    private var reconnectionTimeIntervalStep: Double = 5

    private lazy var mqttSession: MQTTSession = {
        let session = MQTTSession(
            host: host,
            port: port,
            clientID: username,
            cleanSession: true,
            keepAlive: 60,
            useSSL: false
        )
        session.username = username
        session.password = mqttApiKey
        session.delegate = self
        return session
    }()

    func connect() {
        
        mqttSession.connect { [weak self] error in
            guard let self = self else { return }
            if error != .none {
                print("Unable to connect to MQTT Server, error: \(error.localizedDescription)")
            } else {
                print("Connected to MQTT server")
                self.reconnectionTimeInterval = 0
                self.isDisconnectInitiatedByApp = false
                self.subscribeTo(channel: .toiletLightStatus)
            }
        }
    }
    
    func disconnect() {
        
        isDisconnectInitiatedByApp = true
        mqttSession.disconnect()
    }
    
    private func subscribeTo(channel: MQTTChannel) {
        
        let topic = "channels/\(channel.id)/subscribe/\(responseFormat)/\(channel.readApiKey)"
        mqttSession.subscribe(
            to: topic,
            delivering: .atMostOnce,
            completion: { error in
                if error != .none {
                    print("Unable to subscribe to channel, error: \(error.localizedDescription)")
                } else {
                    print("Subscribed to channel")
                }
        })
    }
    
    private func isToiletAvailable(model: ToiletLightStatusModel) -> Bool {
        
        guard let statusValue = Double(model.status) else {
            print("Unable to convert status string to double value")
            return true
        }
        return statusValue < 500
    }
    
    private func scheduleReconnection() {
        
        self.reconnectionTimeInterval += reconnectionTimeIntervalStep
        print("Schedule server reconnection in \(reconnectionTimeInterval) seconds")
        self.reconnectionTimer = Repeater.once(after: .seconds(reconnectionTimeInterval)) { [weak self] timer in
            guard let self = self else { return }
            print("Trying to reconnect ...")
            self.connect()
        }
    }
}

// MARK: - MQTTSessionDelegate
extension StatusMQTTService: MQTTSessionDelegate {
    
    func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        
        do {
            print(message.payload.prettyPrintedJSONString)
            let model = try JSONDecoder().decode(ToiletLightStatusModel.self, from: message.payload)
            delegate?.updateStatus(isToiletAvailable: isToiletAvailable(model: model))
        } catch {
            print("Unable to decode payload: \(error.localizedDescription)")
            delegate?.updateStatus(isToiletAvailable: true)
        }
    }
    
    func mqttDidAcknowledgePing(from session: MQTTSession) {
        
        print("MQTT session keep alive ping")
    }
    
    func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {
        
        print("Disconnect from MQTT server")
        if !isDisconnectInitiatedByApp {
            scheduleReconnection()
        } else {
            isDisconnectInitiatedByApp = false
        }
    }
}

