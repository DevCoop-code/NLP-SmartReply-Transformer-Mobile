//
//  EncoderConverter.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/18.
//

import Foundation

class EncoderConverter {
    var wordTovec: String?
    var wordTovecArray: [Int64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // 길이: 25
    var classifyWordVectorArray: [Int32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // 길이: 25
    
    init?(modelFileInfo: FileInfo) {
        let modelFilename = modelFileInfo.name
        
        guard let classifyWordVectorJsonPath = Bundle.main.path(forResource: modelFilename, ofType: modelFileInfo.extension) else {
            return nil
        }
        
        do {
            wordTovec = try String(contentsOfFile: classifyWordVectorJsonPath)
        } catch {
            print("Fail to load classify_wordtovec json file")
        }
    }
    
    func convertWordToVectorInt64(input: String) -> [Int64] {
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
    
    func convertWordToVectorInt32(input: String) -> [Int32] {
        let oJsonDataT: Data? = wordTovec?.data(using: .utf8)
        
        guard let oJsonData = oJsonDataT else {
            print("Fail to cast JsonData")
            
            return classifyWordVectorArray
        }
        
        var oJsonDictionaryT: [String:Any]?
        oJsonDictionaryT = try! JSONSerialization.jsonObject(with: oJsonData, options: []) as! [String:Any]
        
        guard let oJsonDictionary = oJsonDictionaryT else {
            print("Fail to cast JsonDictionary")
            
            return classifyWordVectorArray
        }
        
        var splittedInputs = input.components(separatedBy: " ")
        for (index, splittedInput) in splittedInputs.enumerated() {
            classifyWordVectorArray[index] = oJsonDictionary[splittedInput] as? Int32 ?? 3
        }
        
        
        return classifyWordVectorArray
        
    }
}
