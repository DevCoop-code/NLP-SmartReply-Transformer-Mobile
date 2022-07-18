//
//  DecoderConverter.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/15.
//

import Foundation

class DecoderConverter {
    var vecToWord: String?
    
    init?() {
        guard let vectowordJsonPath = Bundle.main.path(forResource: "vectoword", ofType: "json") else {
            return nil
        }
        do {
            vecToWord = try String(contentsOfFile: vectowordJsonPath)
        }
        catch {
            print("Fail to load vectoword json file")
        }
    }
    
    func convertVecToWord(key: String) -> String? {
        let oJsonDataT: Data? = vecToWord?.data(using: .utf8)
        
        guard let oJsonData = oJsonDataT else
        {
            print("Fail to cast JsonData")
            return nil
        }
        
        var oJsonDictionaryT:[String:Any]?
        oJsonDictionaryT = try! JSONSerialization.jsonObject(with: oJsonData, options: []) as! [String:Any]
        
        guard let oJsonDictionary = oJsonDictionaryT else
        {
            print("Fail to cast JsonDictionary")
            return nil
        }
        
//        print(oJsonDictionary.keys)
//        print("\(key) : \(oJsonDictionary[key])")
        
        return oJsonDictionary[key] as? String
//        return oJsonDictionary[key] as? String
    }
}
