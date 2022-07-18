//
//  EncoderConverter.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/18.
//

import Foundation

class EncoderConverter {
    var wordTovec: String?
    var wordTovecArray: [Int64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    init?() {
        guard let wordtovecJsonPath = Bundle.main.path(forResource: "wordtovec", ofType: "json") else {
            return nil
        }
        do {
            wordTovec = try String(contentsOfFile: wordtovecJsonPath)
        }
        catch {
            print("Fail to load wordtovec json file")
        }
    }
    
    func convertWordToVector(input: String) -> [Int64] {
        let oJsonDataT: Data? = wordTovec?.data(using: .utf8)
        
        guard let oJsonData = oJsonDataT else {
            print("Fail to cast JsonData")
            return wordTovecArray
        }
        
        var oJsonDictionaryT: [String:Any]?
        oJsonDictionaryT = try! JSONSerialization.jsonObject(with: oJsonData, options: []) as! [String:Any]
        
        guard let oJsonDictionary = oJsonDictionaryT else {
            print("Fail to cast JsonDictionary")
            return wordTovecArray
        }
        
        var splittedInputs = input.components(separatedBy: " ")
        for (index, splittedInput) in splittedInputs.enumerated() {
            wordTovecArray[index] = oJsonDictionary[splittedInput] as? Int64 ?? 3
        }
        
        
        return wordTovecArray
    }
}
