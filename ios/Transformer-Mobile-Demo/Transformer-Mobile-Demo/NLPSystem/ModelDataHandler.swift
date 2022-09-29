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
    
    static let modelInfo: FileInfo = (name: "transformer_output7_input4153026", extension: "tflite")
}

class ModelDataHandler {
    let threadCount: Int
    
    private var interpreter: Interpreter
    
    init?(modelFileInfo: FileInfo, threadCount: Int = 1) {
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
            
//            let encoderInputArray: [Int64] = [92, 80, 36, 82, 87, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            let encoderConverter = EncoderConverter(modelFileInfo: MobileNet.modelInfo)
            let encoderInputArray = encoderConverter!.convertWordToVectorInt64(input: inputStr)
            
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
        
//        print(outputTensor.data)
        
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
        
        let decoderConverter = DecoderConverter()
        
//        print(outputValue_0)
//        print(outputValue_1)
//        print(outputValue_2)
//        print(outputValue_3)
//        print(outputValue_4)
//        print(outputValue_5)
//        print(outputValue_6)
        
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
        
//        let outputStr_0 = decoderConverter?.convertVecToWord(key: String(outputValue_0))
//        let outputStr_1 = decoderConverter?.convertVecToWord(key: String(outputValue_1))
//        let outputStr_2 = decoderConverter?.convertVecToWord(key: String(outputValue_2))
//        let outputStr_3 = decoderConverter?.convertVecToWord(key: String(outputValue_3))
//        let outputStr_4 = decoderConverter?.convertVecToWord(key: String(outputValue_4))
//        let outputStr_5 = decoderConverter?.convertVecToWord(key: String(outputValue_5))
//        let outputStr_6 = decoderConverter?.convertVecToWord(key: String(outputValue_6))
                
//        let predictedResponse = outputStr_0! + " " + outputStr_1! + " " + outputStr_2! + " " + outputStr_3! + " " + outputStr_4! + " " + outputStr_5! + " " + outputStr_6!
        
//        print(outputStr_0!)
//        print(outputStr_1)
//        print(outputStr_2)
//        print(outputStr_3)
//        print(outputStr_4)
//        print(outputStr_5)
//        print(outputStr_6)
        
        print(predictedResponse)
        
        return predictedResponse
    }
}
