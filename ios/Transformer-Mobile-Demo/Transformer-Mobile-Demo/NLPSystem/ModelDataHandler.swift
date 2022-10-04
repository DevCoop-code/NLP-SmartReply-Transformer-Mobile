//
//  ModelDataHandler.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/07/14.
//

import Foundation
import TensorFlowLite

// Information about a model tflite or label file
typealias FileInfo = (name: String, extension: String)

enum MobileNet {
    // 문장의 주제를 분류하기 위한 모델 (Personal, Food, Hobby 3개 중 하나로 분류)
    static let classifyModelInfo:FileInfo = (name: "classify_cnn", extension: "tflite")
    static let classifyJSONInfo: FileInfo = (name: "classify_wordtovec", extension: "json")
    
    static let personalModelInfo: FileInfo = (name: "transformerModel_personal", extension: "tflite")
    static let modelPersonalVecToWordJSONInfo: FileInfo = (name: "transformerPersonalVecToWord", extension: "json")
    static let modelPersonalWordToVecJSONInfo: FileInfo = (name: "transformerPersonalWordToVec", extension: "json")
    
    static let foodModelInfo: FileInfo = (name: "transformerModel_food", extension: "tflite")
    static let modelFoodVecToWordJSONInfo: FileInfo = (name: "transformerFoodVecToWord", extension: "json")
    static let modelFoodWordToVecJSONInfo: FileInfo = (name: "transformerFoodWordToVec", extension: "json")
    
    static let hobbyModelInfo: FileInfo = (name: "transformerModel_hobby", extension: "tflite")
    static let modelHobbyVecToWordJSONInfo: FileInfo = (name: "transformerHobbyVecToWord", extension: "json")
    static let modelHobbyWordToVecJSONInfo: FileInfo = (name: "transformerHobbyWordToVec", extension: "json")
    
    static let morphemizedPersonalJSONInfo: FileInfo = (name: "morphemizedText_personal", extension: "json")
    static let morphemizedFoodJSONInfo: FileInfo = (name: "morphemizedText_food", extension: "json")
    static let morphemizedHobbyJSONInfo: FileInfo = (name: "morphemizedText_hobby", extension: "json")
}

class ModelDataHandler {
    let threadCount: Int
    
    private var interpreter: Interpreter
    
    private var modelInfo: FileInfo
    private var wordToVecInfo: FileInfo
    private var vecToWordInfo: FileInfo
    private var morphemizedInfo: FileInfo
    
    init?(modelFileInfo: FileInfo, wordToVec:FileInfo, vecToWord:FileInfo, morphemized:FileInfo, threadCount: Int = 1) {
        modelInfo = modelFileInfo
        wordToVecInfo = wordToVec
        vecToWordInfo = vecToWord
        morphemizedInfo = morphemized
        
        let modelFilename = modelFileInfo.name
        
        // Construct the path to the model file
        guard let modelPath = Bundle.main.path(forResource: modelFilename, ofType: modelFileInfo.extension) else {
            print("Failed to load the model file with name: \(modelFilename)")
            return nil
        }
        
        // Specify the options for the 'Interpreter'
        self.threadCount = threadCount
        var options = InterpreterOptions()
        options.threadCount = threadCount
        
        // Create the Interpreter
        do {
            interpreter = try Interpreter(modelPath: modelPath, options: options)
        } catch let error {
            print("Failed to create the interpreter with error : \(error.localizedDescription)")
            return nil
        }
    }
    
    func runModel(inputStr: String) -> String?{
        print("runModel")
        
        let outputTensor_0: Tensor
        let outputTensor_1: Tensor
        let outputTensor_2: Tensor
        let outputTensor_3: Tensor
        let outputTensor_4: Tensor
        let outputTensor_5: Tensor
        let outputTensor_6: Tensor
        
        do {
            // Allocate memory for the model's input Tensor's
            try interpreter.allocateTensors()
            
            // let encoderInputArray: [Int64] = [92, 80, 36, 82, 87, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            let textPreprocessor = TextPreprocessor()
            guard let textPreprocessor = textPreprocessor else {
                return nil
            }
            
            // 데이터 전처리
            var inputStr = try textPreprocessor.convertTextForInference(input: inputStr)
            guard let inputStr = inputStr else {
                return nil
            }
            
            // 형태소 분석
            let morphemizedSentence: MorphemizedSentence?
            morphemizedSentence = MorphemizedSentence(modelFileInfo: MobileNet.morphemizedPersonalJSONInfo)
            var morphmizedInputStr = morphemizedSentence?.morphemizeWord(input: inputStr)
            guard let morphmizedInputStr = morphmizedInputStr else {
                return nil
            }
//            print(morphemizedSentence)
            
            // 전처리된 입력텍스트를 Vector의 형태로 변환 (String --> Vector)
            let encoderConverter = EncoderConverter(modelFileInfo: wordToVecInfo)
            let encoderInputArray = encoderConverter!.convertWordToVectorInt64(input: morphmizedInputStr)
            // Vector화된 텍스트 데이터를 Data형태로 변환 (Vector --> Data)
            let encoderInputData = Data(buffer: UnsafeBufferPointer(start: encoderInputArray, count: encoderInputArray.count))
            
            // Copy the input data to the input Tensor
            try interpreter.copy(encoderInputData, toInputAt: 0)
            
            try interpreter.invoke()
            
            outputTensor_0 = try interpreter.output(at: 4)
            outputTensor_1 = try interpreter.output(at: 1)
            outputTensor_2 = try interpreter.output(at: 5)
            outputTensor_3 = try interpreter.output(at: 3)
            outputTensor_4 = try interpreter.output(at: 0)
            outputTensor_5 = try interpreter.output(at: 2)
            outputTensor_6 = try interpreter.output(at: 6)
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
            return nil
        }
        
        let outputData_0 = outputTensor_0.data
        let outputValue_0 = outputData_0.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let outputData_1 = outputTensor_1.data
        let outputValue_1 = outputData_1.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let outputData_2 = outputTensor_2.data
        let outputValue_2 = outputData_2.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let outputData_3 = outputTensor_3.data
        let outputValue_3 = outputData_3.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let outputData_4 = outputTensor_4.data
        let outputValue_4 = outputData_4.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let outputData_5 = outputTensor_5.data
        let outputValue_5 = outputData_5.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let outputData_6 = outputTensor_6.data
        let outputValue_6 = outputData_6.withUnsafeBytes{$0.load(as: Int64.self)}
        
        let decoderConverter = DecoderConverter(modelFileInfo: vecToWordInfo)
        
        var predictedResponse = "";
        if outputValue_0 > 3 {
            let outputStr_0 = decoderConverter?.convertVecToWord(key: String(outputValue_0))
            
            predictedResponse = outputStr_0!
        }
        if outputValue_1 > 3 {
            let outputStr_1 = decoderConverter?.convertVecToWord(key: String(outputValue_1))
            
            predictedResponse = predictedResponse + " " + outputStr_1!
        }
        if outputValue_2 > 3 {
            let outputStr_2 = decoderConverter?.convertVecToWord(key: String(outputValue_2))
            
            predictedResponse = predictedResponse + " " + outputStr_2!
        }
        if outputValue_3 > 3 {
            let outputStr_3 = decoderConverter?.convertVecToWord(key: String(outputValue_3))
            
            predictedResponse = predictedResponse + " " + outputStr_3!
        }
        if outputValue_4 > 3 {
            let outputStr_4 = decoderConverter?.convertVecToWord(key: String(outputValue_4))
            
            predictedResponse = predictedResponse + " " + outputStr_4!
        }
        if outputValue_5 > 3 {
            let outputStr_5 = decoderConverter?.convertVecToWord(key: String(outputValue_5))
            
            predictedResponse = predictedResponse + " " + outputStr_5!
        }
        if outputValue_6 > 3 {
            let outputStr_6 = decoderConverter?.convertVecToWord(key: String(outputValue_6))
            
            predictedResponse = predictedResponse + " " + outputStr_6!
        }
        
        print(predictedResponse)
        
        return predictedResponse
    }
}
