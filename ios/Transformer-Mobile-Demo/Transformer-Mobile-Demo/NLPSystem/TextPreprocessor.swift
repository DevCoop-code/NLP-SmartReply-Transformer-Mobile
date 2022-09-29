//
//  TextPreprocessor.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/09/28.
//

import Foundation

class TextPreprocessor {
    
    init?() {
        
    }
    
    // 분류를 하기 위한 텍스트 전처리
    func convertTextForClassification(input: String) throws -> String? {
        var preprocessedInputStr: String? = nil
        
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "[^ 가-힣 ㄱ-ㅎ ㅏ-ㅣ # @ 0-9]")
        let regex2:NSRegularExpression = try NSRegularExpression(pattern: "[ㅋㅎㄴㅜㅠㄷㄱㅅ]")
        preprocessedInputStr = regex.stringByReplacingMatches(in: input,
                                                                      options: [],
                                                                      range: NSMakeRange(0, input.count),
                                                                      withTemplate: "")
        guard var preprocessedInputStr = preprocessedInputStr else {
            return preprocessedInputStr
        }

        preprocessedInputStr = regex2.stringByReplacingMatches(in: preprocessedInputStr,
                                                               options: [],
                                                               range: NSMakeRange(0, preprocessedInputStr.count),
                                                               withTemplate: "")
        return preprocessedInputStr;
    }
}
