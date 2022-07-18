//
//  ModelData.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/18.
//

import Foundation

struct Message: Hashable {
    var content: String
    var user: User
}

struct User: Hashable {
    var name: String
    var avatar: String
    var isCurrentUser: Bool = false
}
