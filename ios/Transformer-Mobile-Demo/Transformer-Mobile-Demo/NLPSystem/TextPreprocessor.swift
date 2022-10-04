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
    
    func convertTextForInference(input: String) throws -> String? {
        var preprocessedInputStr: String? = nil
        
        var input = input.replacingOccurrences(of: "ㅋㅋㅋㅋㅋ", with: "ㅋ").replacingOccurrences(of: "ㅋㅋㅋㅋ", with: "ㅋ").replacingOccurrences(of: "ㅋㅋㅋ", with: "ㅋ").replacingOccurrences(of: "ㅋㅋ", with: "ㅋ")
        input = input.replacingOccurrences(of: "ㅎㅎㅎㅎㅎ", with: "ㅎ").replacingOccurrences(of: "ㅎㅎㅎㅎ", with: "ㅎ").replacingOccurrences(of: "ㅎㅎㅎ", with: "ㅎ").replacingOccurrences(of: "ㅎㅎ", with: "ㅎ")
        input = input.replacingOccurrences(of: "!!!!!", with: "!").replacingOccurrences(of: "!!!!", with: "!").replacingOccurrences(of: "!!!", with: "!").replacingOccurrences(of: "!!", with: "!")
        input = input.replacingOccurrences(of: "?????", with: "?").replacingOccurrences(of: "????", with: "?").replacingOccurrences(of: "???", with: "?").replacingOccurrences(of: "??", with: "?")
        input = input.replacingOccurrences(of: "ㅜㅜㅜㅜㅜ", with: "ㅜ").replacingOccurrences(of: "ㅜㅜㅜㅜ", with: "ㅜ").replacingOccurrences(of: "ㅜㅜㅜ", with: "ㅜ").replacingOccurrences(of: "ㅜㅜ", with: "ㅜ")
        input = input.replacingOccurrences(of: "ㅠㅠㅠㅠㅠ", with: "ㅠ").replacingOccurrences(of: "ㅠㅠㅠㅠ", with: "ㅠ").replacingOccurrences(of: "ㅠㅠㅠ", with: "ㅠ").replacingOccurrences(of: "ㅠㅠ", with: "ㅠ")
        
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "([~.,!\"':;)(])")
        preprocessedInputStr = regex.stringByReplacingMatches(in: input,
                                                              options: [],
                                                              range: NSMakeRange(0, input.count),
                                                              withTemplate: "")
        return preprocessedInputStr
    }
}
