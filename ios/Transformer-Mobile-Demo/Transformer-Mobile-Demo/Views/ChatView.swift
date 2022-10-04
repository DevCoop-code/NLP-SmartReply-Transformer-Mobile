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
    let transformerPersonalModelHandler: ModelDataHandler?
    let transformerFoodModelHandler: ModelDataHandler?
    let transformerHobbyModelHandler: ModelDataHandler?
    
    // 분류 하기 위한 CNN Classifier Model
    let textClassifier: TextClassifier?
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
        
        textClassifier = TextClassifier(modelFileInfo: MobileNet.classifyModelInfo)
        
        transformerPersonalModelHandler = ModelDataHandler(modelFileInfo: MobileNet.personalModelInfo,
                                                           wordToVec: MobileNet.modelPersonalWordToVecJSONInfo,
                                                           vecToWord: MobileNet.modelPersonalVecToWordJSONInfo,
                                                           morphemized: MobileNet.morphemizedPersonalJSONInfo)
        transformerFoodModelHandler = ModelDataHandler(modelFileInfo: MobileNet.foodModelInfo,
                                                       wordToVec: MobileNet.modelFoodWordToVecJSONInfo,
                                                       vecToWord: MobileNet.modelFoodVecToWordJSONInfo,
                                                       morphemized: MobileNet.morphemizedFoodJSONInfo)
        transformerHobbyModelHandler = ModelDataHandler(modelFileInfo: MobileNet.hobbyModelInfo,
                                                       wordToVec: MobileNet.modelHobbyWordToVecJSONInfo,
                                                       vecToWord: MobileNet.modelHobbyVecToWordJSONInfo,
                                                        morphemized: MobileNet.morphemizedHobbyJSONInfo)
        
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
        
        var classifierResult = textClassifier?.classifyTheSentence(inputStr: typingMessage)
        guard let classifierResult = classifierResult else {
            return
        }
        
        var maxIndex = 0;
        if classifierResult[0] < classifierResult[1] {
            if classifierResult[1] < classifierResult[2] {
                maxIndex = 2
            } else {
                maxIndex = 1
            }
        } else {
            if classifierResult[0] < classifierResult[2] {
                maxIndex = 2
            } else {
                maxIndex = 0
            }
        }
        
        var predictedResponse: String?
        if (maxIndex == 0) {
            predictedResponse = transformerPersonalModelHandler?.runModel(inputStr: typingMessage)
        } else if (maxIndex == 1) {
            predictedResponse = transformerFoodModelHandler?.runModel(inputStr: typingMessage)
        } else {
            predictedResponse = transformerHobbyModelHandler?.runModel(inputStr: typingMessage)
        }
        
        guard let predictedResponse = predictedResponse else {
            return
        }
        chatHelper.sendMessage(Message(content: predictedResponse, user: User(name: "Ryan", avatar: "ryanicon", isCurrentUser: false)))

        typingMessage = ""
    }
}

struct ChatView_Previews: PreviewProvider {
    static let chatHelper = ChatHelper()
    
    static var previews: some View {
        ChatView().environmentObject(chatHelper)
    }
}
