//
//  TextClassifier.swift
//  Transformer-Mobile-Demo
//
//  Created by HanGyo Jeong on 2022/09/29.
//

import Foundation
import TensorFlowLite

class TextClassifier {
    let threadCount: Int
    
    private var interpreter: Interpreter
    
    init?(modelFileInfo: FileInfo, threadCount: Int = 1) {
        let modelFilename = modelFileInfo.name
        
        guard let modelPath = Bundle.main.path(forResource: modelFilename, ofType: modelFileInfo.extension) else {
            print("Failed to load the model file with name: \(modelFilename)")
            return nil
        }
        
        self.threadCount = threadCount
        
        var options = InterpreterOptions()
        options.threadCount = threadCount
        
        // Create the Interpreter
        do {
            interpreter = try Interpreter(modelPath: modelPath, options: options)
        } catch let error {
            print("Failed to create the interpreter with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func classifyTheSentence(inputStr: String) -> [Float32]? {
        print("Classify the Sentence")
        
        let outputTensor: Tensor
        
        do {
            try interpreter.allocateTensors()

            let textPreprocessor = TextPreprocessor()
            let encoderConverter = EncoderConverter(modelFileInfo: MobileNet.classifyJSONInfo)
            
            // 입력된 텍스트 전처리
            let preprocessedText = try textPreprocessor?.convertTextForClassification(input: inputStr)
            guard let preprocessedText = preprocessedText else {
                return nil
            }
            // 전처리된 입력텍스트를 Vector의 형태로 변환 (String --> Vector)
            let encoderInputArray = encoderConverter?.convertWordToVectorInt32(input: preprocessedText)
            guard let encoderInputArray = encoderInputArray else {
                return nil
            }
            // Vector화된 텍스트 데이터를 Data형태로 변환 (Vector --> Data)
            let encoderInputData = Data(buffer: UnsafeBufferPointer(start: encoderInputArray, count: encoderInputArray.count))
            
            try interpreter.copy(encoderInputData, toInputAt: 0)
            try interpreter.invoke()
            outputTensor = try interpreter.output(at: 0)
            
            // Float32가 4byte이므로 fromByteOffset은 4단위로 증감소 시켜야 함
            let outputData = outputTensor.data
            let outputValue_0 = outputData.withUnsafeBytes{$0.load(fromByteOffset: 0, as: Float32.self)}
            let outputValue_1 = outputData.withUnsafeBytes{$0.load(fromByteOffset: 4, as: Float32.self)}
            let outputValue_2 = outputData.withUnsafeBytes{$0.load(fromByteOffset: 8, as: Float32.self)}
            
            // 0: Personal, 1: Food, 2: Hobby
            print(outputValue_0)
            print(outputValue_1)
            print(outputValue_2)
            
            let classifyResult: [Float32] = [outputValue_0, outputValue_1, outputValue_2]
            return classifyResult
            
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
        }
        
        return nil
    }
}
