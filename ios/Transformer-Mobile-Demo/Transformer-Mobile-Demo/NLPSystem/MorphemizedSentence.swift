//
//  MorphemizedSentence.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/09/30.
//

import Foundation

class MorphemizedSentence {
    var morphemizedJSONText: String?
    
    init?(modelFileInfo: FileInfo) {
        let modelFilename = modelFileInfo.name
        
        guard let morphemizedJsonPath = Bundle.main.path(forResource: modelFilename, ofType: modelFileInfo.extension) else {
            return nil
        }
        do {
            morphemizedJSONText = try String(contentsOfFile: morphemizedJsonPath)
        }
        catch {
            print("Fail to load vectoword json file")
        }
    }
    
    func morphemizeWord(input: String) -> String? {
        let morphemizedDataT: Data? = morphemizedJSONText?.data(using: .utf8)
        
        guard let morphemizedDataT = morphemizedDataT else {
            print("Fail to cast JsonData")
            return nil
        }
        
        var oJsonDictionaryT: [String:Any]?
        oJsonDictionaryT = try! JSONSerialization.jsonObject(with: morphemizedDataT, options: []) as! [String:Any]

        guard let oJsonDictionary = oJsonDictionaryT else {
            print("Fail to cast JSONDictionary")
            return nil
        }
        
        var morphemizedSentence = ""
        var splittedInputs = input.components(separatedBy: " ")
        for (index, splittedInput) in splittedInputs.enumerated() {
            var morphemizedWord = oJsonDictionary[splittedInput] as? String ?? splittedInput
            morphemizedSentence = morphemizedSentence + morphemizedWord + " "
        }
        
        return morphemizedSentence
    }
}
