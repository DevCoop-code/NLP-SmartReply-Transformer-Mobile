//
//  ContentView.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ChatView().environmentObject(ChatHelper())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ChatHelper())
    }
}
