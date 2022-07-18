//
//  ChatHelper.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/18.
//

import Foundation

class ChatHelper: ObservableObject {
    @Published var realTimeMessages: [Message] = []
    
    func sendMessage(_ chatMsg: Message) {
        realTimeMessages.append(chatMsg)
    }
}
