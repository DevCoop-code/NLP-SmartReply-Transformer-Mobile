//
//  MessageView.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/18.
//

import SwiftUI

struct MessageView: View {
    
    var currentMessage: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if !currentMessage.user.isCurrentUser {
                Image("ryanicon")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
            } else {
                Spacer()
            }
            
            ContentMessageView(contentMessage: currentMessage.content,
                               isCurrentUser: currentMessage.user.isCurrentUser)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(currentMessage: Message(content: "There are a lot of premium solution",
                                            user: User(name: "other", avatar: "otherguy", isCurrentUser: true)))
    }
}
