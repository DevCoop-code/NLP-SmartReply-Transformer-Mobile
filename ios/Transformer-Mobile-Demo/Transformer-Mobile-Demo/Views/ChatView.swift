//
//  ChatView.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/18.
//

import SwiftUI

struct ChatView: View {
    @State var typingMessage: String = ""
    @EnvironmentObject var chatHelper: ChatHelper
    
    // 추론 하기 위한 Transformer Model
    let transformerModelHandler: ModelDataHandler?
    // 분류 하기 위한 CNN Classifier Model
    let textClassifier: TextClassifier?
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
        
        transformerModelHandler = ModelDataHandler(modelFileInfo: MobileNet.modelInfo)
        textClassifier = TextClassifier(modelFileInfo: MobileNet.classifyModelInfo)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(chatHelper.realTimeMessages, id: \.self) {
                    msg in MessageView(currentMessage: msg).listRowSeparator(.hidden)
                }
            }
            
            HStack {
                TextField("Message...", text:$typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                Button(action:sendMessage) {
                    Text("Send")
                }
            }.frame(minHeight: CGFloat(50)).padding()
        }
    }
    
    func sendMessage() {
        
        chatHelper.sendMessage(Message(content: typingMessage, user: User(name: "Ryan", avatar: "ryanicon", isCurrentUser: true)))
        
        textClassifier?.classifyTheSentence(inputStr: typingMessage)
//        guard let predictedResponse = transformerModelHandler?.runModel(inputStr: typingMessage) else {
//            return
//        }
        
//        chatHelper.sendMessage(Message(content: predictedResponse, user: User(name: "Ryan", avatar: "ryanicon", isCurrentUser: false)))

        typingMessage = ""
    }
}

struct ChatView_Previews: PreviewProvider {
    static let chatHelper = ChatHelper()
    
    static var previews: some View {
        ChatView().environmentObject(chatHelper)
    }
}
