//
//  StatusMQTTService.swift
//  iToilet
//
//  Created by Roman Anistratenko on 11.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Foundation
import SwiftMQTT

protocol StatusMQTTServiceDelegate: class {
    
    func updateStatus(isToiletAvailable: Bool)
    func updateConnectionStatus(isConnected: Bool)
}

final class StatusMQTTService {

    weak var delegate: StatusMQTTServiceDelegate?
    
    private let username = "miha25255"
    private let host = "mqtt.thingspeak.com"
    private let port: UInt16 = 1883
    private let mqttApiKey = "FVRIJXU8MB0L8K5U"
    private let responseFormat = "json"
    private var isDisconnectInitiatedByApp = false
    private var reconnectionTimer: Timer?
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
                log.error("Unable to connect to MQTT Server, error: \(error.localizedDescription)", .network)
            } else {
                log.info("Connected to MQTT server", .network)
                self.delegate?.updateConnectionStatus(isConnected: true)
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
                    log.error("Unable to subscribe to channel, error: \(error.localizedDescription)", .network)
                } else {
                    log.info("Subscribed to channel", .network)
                }
        })
    }
    
    private func isToiletAvailable(model: ToiletLightStatusModel) -> Bool {
        
        guard let statusValue = Double(model.status) else {
            log.error("Unable to convert status string to double value", .network)
            return true
        }
        return statusValue < 500
    }
    
    private func scheduleReconnection() {
        
        self.reconnectionTimeInterval += reconnectionTimeIntervalStep
        log.info("Schedule server reconnection in \(reconnectionTimeInterval) seconds", .network)
        self.reconnectionTimer = Timer.once(after: .seconds(reconnectionTimeInterval))
        self.reconnectionTimer?.delegate = self
    }
}

// MARK: - MQTTSessionDelegate
extension StatusMQTTService: MQTTSessionDelegate {
    
    func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        
        do {
            log.info(String(message.payload.prettyPrintedJSONString), .network)
            let model = try JSONDecoder().decode(ToiletLightStatusModel.self, from: message.payload)
            delegate?.updateStatus(isToiletAvailable: isToiletAvailable(model: model))
        } catch {
            log.error("Unable to decode payload: \(error.localizedDescription)", .network)
            delegate?.updateStatus(isToiletAvailable: true)
        }
    }
    
    func mqttDidAcknowledgePing(from session: MQTTSession) {
        
        log.info("MQTT session keep alive ping", .network)
    }
    
    func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {
        
        log.info("Disconnect from MQTT server", .network)
        delegate?.updateConnectionStatus(isConnected: false)
        if !isDisconnectInitiatedByApp {
            scheduleReconnection()
        } else {
            isDisconnectInitiatedByApp = false
        }
    }
}

// MARK: - TimerDelegate
extension StatusMQTTService: TimerDelegate {
    
    func timerDidFire(_ timer: Timer) {
        
        log.info("Trying to reconnect ...", .network)
        connect()
    }
}
