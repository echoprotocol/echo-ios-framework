//
//  AbiArgumentInterpretatorImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 02.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//
import ECHO.Private

class ArrayOfData {
    var array = [Data]()
}

final public class AbiArgumentCoderImp: AbiArgumentCoder {
    
    let sliceSize = 32
    let addressSize = 20
    let contractAddressFirstPartValue: UInt8 = 1
    let ethAddressHexFirstByte = "0x"
    
    public init() { }
    
    public func getArguments(valueTypes: [AbiTypeValueInputModel]) throws -> Data {
        
        let staticData = ArrayOfData()
        let dynamicData = ArrayOfData()
        var offset = sliceSize * valueTypes.count
        
        //encode data
        for index in 0..<valueTypes.count {
            
            let type = valueTypes[index].type
            let value = valueTypes[index].value
            
            //encode arrays
            if type.isArray() {
                
                if type.isDynamicElementaryArray() {
                    
                    offset = try encodeElementaryDynamicArray(staticStack: staticData,
                                                              dynamicStack: dynamicData, type: type, offset: offset, data: value)
                } else if type.isFixedElementaryArray() {
                    
                    offset = try encodeElementaryStaticArray(staticStack: staticData,
                                                             dynamicStack: dynamicData, type: type, offset: offset, data: value)
                } else if type == AbiParameterType.dynamicArrayOfStrings {
                    
                    offset = try encodeDynamicStringArray(staticStack: staticData, dynamicStack: dynamicData, type: type, offset: offset, data: value)
                }
            }
            
            //encode primitive types
            else if type.isPrimitive() {
                
                try encodePrimitiveTypes(staticStack: staticData, type: type, offset: offset, data: value)
            } else if type == AbiParameterType.address {
                
                try encodeAddress(staticStack: staticData, type: type, offset: offset, data: value)
            } else if type == AbiParameterType.contractAddress {
                
                try encodeContractAddress(staticStack: staticData, type: type, offset: offset, data: value)
            } else if type == AbiParameterType.ethContractAddress {
                
                try encodeETHContractAddress(staticStack: staticData, type: type, offset: offset, data: value)
            } else if type == AbiParameterType.string {
                
                offset = try encodeString(staticStack: staticData, dynamicStack: dynamicData, type: type, offset: offset, data: value)
            } else if type == AbiParameterType.bytes {
                
                offset = try encodeBytes(staticStack: staticData, dynamicStack: dynamicData, type: type, offset: offset, data: value)
            }
        }
        
        var args = Data()
        
        for index in 0..<staticData.array.count {
            args.append(staticData.array[index])
        }
        
        for index in 0..<dynamicData.array.count {
            args.append(dynamicData.array[index])
        }
        
        return args
    }
    
    public func getValueTypes(data: Data, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel] {
        
        return try decodeOutputs(data: data, outputs: outputs)
    }
    
    public func getValueTypes(string: String, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel] {
        
        if let data = Data(hex: string) {
            return try decodeOutputs(data: data, outputs: outputs)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
}

private typealias Decoder = AbiArgumentCoderImp
extension Decoder {
    
    fileprivate func decodePrimitives(_ data: Data,
                                      _ sliceIndex: Int,
                                      _ type: AbiParameterType,
                                      _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        
        let start = sliceSize * sliceIndex
        let end = start + sliceSize
        
        guard let btcNumber = BTCBigNumber(unsignedBigEndian: data[safe: start..<end]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let output = AbiTypeValueOutputModel(type: type, value: btcNumber.decimalString)
        decodedOutputs.append(output)
    }
    
    fileprivate func decodeAddress(_ data: Data,
                                   _ sliceIndex: Int,
                                   _ type: AbiParameterType,
                                   _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        
        let start = sliceSize * sliceIndex
        var end = start + sliceSize
        
        if end > data.count {
            end = start + addressSize
        }
        
        guard var addressData = data[safe: start..<end] else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        if addressData.count == sliceSize {
            addressData.removeFirst(sliceSize - addressSize)
        }
        
        if addressData.bytes.first == 1 {
            try decodeContractAddress(data, sliceIndex, .contractAddress, &decodedOutputs)
            return
        }
        
        guard let btcNumber = BTCBigNumber(unsignedBigEndian: addressData) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let output = AbiTypeValueOutputModel(type: type, value: btcNumber.decimalString)
        decodedOutputs.append(output)
    }
    
    fileprivate func decodeContractAddress(_ data: Data,
                                           _ sliceIndex: Int,
                                           _ type: AbiParameterType,
                                           _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        
        let start = sliceSize * sliceIndex
        var end = start + sliceSize
        
        if end > data.count {
            end = start + addressSize
        }
        
        guard var addressData = data[safe: start..<end] else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        if addressData.count == sliceSize {
            addressData.removeFirst(sliceSize - addressSize)
        }
        
        addressData.removeFirst()
        
        guard let btcNumber = BTCBigNumber(unsignedBigEndian: addressData) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let output = AbiTypeValueOutputModel(type: type, value: btcNumber.decimalString)
        decodedOutputs.append(output)
    }
    
    fileprivate func decodeETHAddress(_ data: Data,
                                      _ sliceIndex: Int,
                                      _ type: AbiParameterType,
                                      _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        
        let start = sliceSize * sliceIndex
        let end = start + sliceSize
        
        guard let bytesData = data[safe: start..<end] else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        guard let fixedBytesData = bytesData[safe: sliceSize-addressSize..<sliceSize] else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        var ethAddressHex = ethAddressHexFirstByte
        ethAddressHex.append(fixedBytesData.hex)
        
        let output = AbiTypeValueOutputModel(type: type, value: ethAddressHex)
        decodedOutputs.append(output)
    }
    
    fileprivate func decodeStrings(_ data: Data,
                                   _ sliceIndex: Int,
                                   _ type: AbiParameterType,
                                   _ decodedOutputs: inout [AbiTypeValueOutputModel],
                                   _ outputs: [AbiFunctionEntries]) throws {
        
        var start = sliceSize * sliceIndex
        var end = start + sliceSize
        
        guard let btcNumber = BTCBigNumber(unsignedBigEndian: data[safe: start..<end]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let offset = Int(btcNumber.uint32value)
        
        guard let lenght = BTCBigNumber(unsignedBigEndian: data[safe: offset..<offset + sliceSize]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        start = sliceSize + offset
        end = sliceSize + offset + Int(lenght.uint32value)
        
        let data = data[safe: start..<end]
        
        if let sringOutput = stringFrom(data: data) {
            let output = AbiTypeValueOutputModel(type: type, value: sringOutput)
            decodedOutputs.append(output)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    fileprivate func decodeBytes(_ data: Data,
                                 _ sliceIndex: Int,
                                 _ type: AbiParameterType,
                                 _ decodedOutputs: inout [AbiTypeValueOutputModel],
                                 _ outputs: [AbiFunctionEntries]) throws {
        
        var start = sliceSize * sliceIndex
        var end = start + sliceSize
        
        guard let btcNumber = BTCBigNumber(unsignedBigEndian: data[safe: start..<end]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let offset = Int(btcNumber.uint32value)
        
        guard let lenght = BTCBigNumber(unsignedBigEndian: data[safe: offset..<offset + sliceSize]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        start = sliceSize + offset
        end = sliceSize + offset + Int(lenght.uint32value)
        
        let data = data[safe: start..<end]
        
        if let sringOutput = stringFrom(data: data) {
            let output = AbiTypeValueOutputModel(type: type, value: sringOutput)
            decodedOutputs.append(output)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    fileprivate func decodeDynamicArrayOfInt(_ data: Data,
                                             _ sliceIndex: Int,
                                             _ type: AbiParameterType,
                                             _ decodedOutputs: inout [AbiTypeValueOutputModel],
                                             _ outputs: [AbiFunctionEntries]) throws {
        
        let start = sliceSize * sliceIndex
        let end = start + sliceSize
        
        guard let offsetNumber = BTCBigNumber(unsignedBigEndian: data[safe: start..<end]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let offset = Int(offsetNumber.uint32value)
        
        guard let lenghtNumber = BTCBigNumber(unsignedBigEndian: data[safe: offset..<offset + sliceSize]) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let lenght = Int(lenghtNumber.uint32value)
        var resultString = ""
        
        for index in 0..<lenght {
            
            let start = sliceSize + offset + index * sliceSize
            let end = start + sliceSize
            
            guard let btcNumber = BTCBigNumber(unsignedBigEndian: data[safe: start..<end]) else {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                throw error
            }
            
            resultString += btcNumber.decimalString

            if index != lenght - 1 {
                resultString += ","
            }
        }

        resultString = "[\(resultString)]"
        let output = AbiTypeValueOutputModel(type: type, value: resultString)
        decodedOutputs.append(output)
    }
    
    fileprivate func decodeFixedBytes(_ data: Data,
                                      _ sliceIndex: Int,
                                      _ bytesSize: Int,
                                      _ type: AbiParameterType,
                                      _ decodedOutputs: inout [AbiTypeValueOutputModel],
                                      _ outputs: [AbiFunctionEntries]) throws {
        
        let start = sliceSize * sliceIndex
        let end = start + sliceSize
        
        guard let bytesData = data[safe: start..<end] else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        guard let fixedBytesData = bytesData[safe: 0..<bytesSize] else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        guard let fixedString = String(data: fixedBytesData, encoding: .utf8) else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        let output = AbiTypeValueOutputModel(type: type, value: fixedString)
        decodedOutputs.append(output)
    }
    
    fileprivate func decodeArrayOfAddresses(_ size: Int,
                                            _ outputsData: inout Data,
                                            _ type: AbiParameterType,
                                            _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        var addresses = [String]()
        for index in 0..<size {
            let startIndex = sliceSize * index
            let endIndex = sliceSize * index + sliceSize
            if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: startIndex..<endIndex)) {
                addresses.append(btcNumber.decimalString)
            }
        }
        
        if let newData = outputsData[safe: size * sliceSize..<outputsData.count] {
            let output = AbiTypeValueOutputModel(type: type, value: addresses)
            decodedOutputs.append(output)
            
            outputsData = newData
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    fileprivate func decodeFixedArrayOfBool(_ size: Int,
                                            _ outputsData: inout Data,
                                            _ type: AbiParameterType,
                                            _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        var bools = [Bool]()
        for index in 0..<size {
            let startIndex = sliceSize * index
            let endIndex = sliceSize * index + sliceSize
            if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: startIndex..<endIndex)),
                let intValue = Int(btcNumber.decimalString) {
                bools.append(intValue == 1)
            }
        }
        
        if let newData = outputsData[safe: size * sliceSize..<outputsData.count] {
            let output = AbiTypeValueOutputModel(type: type, value: bools)
            decodedOutputs.append(output)
            
            outputsData = newData
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    fileprivate func decodeFixedArrayOfInt(_ size: Int,
                                           _ outputsData: inout Data,
                                           _ type: AbiParameterType,
                                           _ decodedOutputs: inout [AbiTypeValueOutputModel]) throws {
        var ints = [Int]()
        for index in 0..<size {
            let startIndex = sliceSize * index
            let endIndex = sliceSize * index + sliceSize
            if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: startIndex..<endIndex)),
                let intValue = Int(btcNumber.decimalString) {
                ints.append(intValue)
            }
        }
        
        if let newData = outputsData[safe: size * sliceSize..<outputsData.count] {
            let output = AbiTypeValueOutputModel(type: type, value: ints)
            decodedOutputs.append(output)
            
            outputsData = newData
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    fileprivate func decodeOutputs(data: Data, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel] {
        
        guard data.count > 0 else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        var decodedOutputs = [AbiTypeValueOutputModel]()
        var outputsData = data
        
        for index in 0..<outputs.count {
            
            let type = outputs[index].type
            
            switch type {
            case .uint, .int, .bool:
                
                try decodePrimitives(data, index, type, &decodedOutputs)
            case .address:
                
                try decodeAddress(data, index, type, &decodedOutputs)
            case .contractAddress:
                
                try decodeContractAddress(data, index, type, &decodedOutputs)
            case .ethContractAddress:
                
                try decodeETHAddress(data, index, type, &decodedOutputs)
            case .string:
                
                try decodeStrings(data, index, type, &decodedOutputs, outputs)
            case .bytes:
                
                try decodeBytes(data, index, type, &decodedOutputs, outputs)
            case .dynamicArrayOfUint:
                
                try decodeDynamicArrayOfInt(data, index, type, &decodedOutputs, outputs)
            case .fixedBytes(let size):
                
                try decodeFixedBytes(data, index, size, type, &decodedOutputs, outputs)
            case .fixedArrayOfAddresses(let size):
                
                try decodeArrayOfAddresses(size, &outputsData, type, &decodedOutputs)
            case .fixedArrayOfBool(let size):
                
                try decodeFixedArrayOfBool(size, &outputsData, type, &decodedOutputs)
            case .fixedArrayOfInt(let size), .fixedArrayOfUint(let size):
                
                try decodeFixedArrayOfInt(size, &outputsData, type, &decodedOutputs)
            default:
                break
            }
        }
        
        return decodedOutputs
    }
    
    fileprivate func stringFrom(data: Data?) -> String? {
        
        if let data = data, data.count != 0 {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

private typealias Encoder = AbiArgumentCoderImp
extension Encoder {
    
    fileprivate func encodePrimitiveTypes(staticStack: ArrayOfData, type: AbiParameterType, offset: Int, data: String) throws {
        
        switch type {
            
        case .uint, .int:
    
            staticStack.array.append(BTCBigNumber(decimalString: data).unsignedBigEndian ?? placeholderData())
        case .bool:
            
            if data == "true" {
                staticStack.array.append(BTCBigNumber(decimalString: "1").unsignedBigEndian ?? placeholderData())
            } else if data == "false" {
                staticStack.array.append(BTCBigNumber(decimalString: "0").unsignedBigEndian ?? placeholderData())
            } else {
                staticStack.array.append(BTCBigNumber(decimalString: data).unsignedBigEndian ?? placeholderData())
            }
        case .fixedBytes(let size):
            
            var value = Data(data.utf8)
            
            if value.count > size {
                value = value.subdata(in: 0..<size)
            }
            
            let fillData = Data(count: sliceSize - value.count)
            value.append(fillData)
            
            staticStack.array.append(value)

        default:
            break
        }
    }
    
    fileprivate func encodeAddress(staticStack: ArrayOfData, type: AbiParameterType, offset: Int, data: String) throws {
        
        staticStack.array.append(BTCBigNumber(decimalString: data).unsignedBigEndian ?? placeholderData())
    }
    
    fileprivate func encodeContractAddress(staticStack: ArrayOfData, type: AbiParameterType, offset: Int, data: String) throws {
        
        if var value = BTCBigNumber(decimalString: data).unsignedBigEndian {
            value[sliceSize - addressSize] = contractAddressFirstPartValue
            staticStack.array.append(value)
        } else {
            staticStack.array.append(placeholderData())
        }
    }
    
    fileprivate func encodeETHContractAddress(staticStack: ArrayOfData, type: AbiParameterType, offset: Int, data: String) throws {
        
        var addressHex = data
        if addressHex.count > addressSize * 2 {
            addressHex.removeFirst(ethAddressHexFirstByte.count)
        }
        
        if var value = Data(hex: addressHex) {
            
            value = fillSlice(data: value)
            staticStack.array.append(value)
            
        } else {
            staticStack.array.append(placeholderData())
        }
    }
    
    fileprivate func encodeString(staticStack: ArrayOfData,
                                  dynamicStack: ArrayOfData,
                                  type: AbiParameterType,
                                  offset: Int,
                                  data: String) throws -> Int {
        
        //adding offset
        staticStack.array.append(BTCBigNumber(int64: Int64(offset)).unsignedBigEndian ?? placeholderData())
        
        //adding dynamic data in dynamic stack
        let lenght = data.data(using: .utf8)?.count ?? 0
        
        dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())
        
        let stringData = dataMultiply32bit(string: data)
        dynamicStack.array.append(stringData ?? placeholderData())

        return offset + sliceSize + (stringData?.count ?? 0)
    }
    
    fileprivate func encodeElementaryDynamicArray(staticStack: ArrayOfData,
                                                  dynamicStack: ArrayOfData,
                                                  type: AbiParameterType,
                                                  offset: Int,
                                                  data: String) throws -> Int {
        
        //adding offset
        staticStack.array.append(BTCBigNumber(int64: Int64(offset)).unsignedBigEndian ?? placeholderData())
        
        //adding dynamic data in dynamic stack
        let arrayElements = data.dynamicArrayElementsFromParameter()
        let lenght = arrayElements.count
        
        //adding array elements count
        dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

        switch type {
        case .dynamicArrayOfInt, .dynamicArrayOfUint:
            
            for index in 0..<arrayElements.count {
                
                let element = arrayElements[index]
                dynamicStack.array.append(BTCBigNumber(decimalString: element).unsignedBigEndian ?? placeholderData())
            }
        case .dynamicArrayOfBool:
            
            for index in 0..<arrayElements.count {
                
                let element = arrayElements[index]
                
                if element == "true" {
                    dynamicStack.array.append(BTCBigNumber(decimalString: "1").unsignedBigEndian ?? placeholderData())
                } else if element == "false" {
                    dynamicStack.array.append(BTCBigNumber(decimalString: "0").unsignedBigEndian ?? placeholderData())
                } else {
                    dynamicStack.array.append(BTCBigNumber(decimalString: element).unsignedBigEndian ?? placeholderData())
                }
            }
            
        case .dynamicArrayOfAddresses:
            
            for index in 0..<arrayElements.count {
                
                let element = arrayElements[index]
                
                if var value = Base58.decode(element) as Data? {
                    
                    if value.count == 25 {
                        value = value.subdata(in: 1..<21)
                    }
                    
                    value = fillSlice(data: value)
                    dynamicStack.array.append(value)
                    
                } else {
                    dynamicStack.array.append(placeholderData())
                }
            }
            
        case .dynamicArrayOfFixedBytes(let size):
            
            for index in 0..<arrayElements.count {
                
                let element = arrayElements[index]
                
                if var value = element.data(using: .ascii) {
                    
                    if value.count > size {
                        value = value.subdata(in: 0..<size)
                    }
                    
                    let fillData = Data(count: sliceSize - value.count)
                    value.append(fillData)
                    
                    dynamicStack.array.append(value)
                    
                } else {
                    dynamicStack.array.append(placeholderData())
                }
            }
        default:
            break
        }
        
        return offset + lenght * sliceSize + sliceSize
    }
    
    fileprivate func encodeElementaryStaticArray(staticStack: ArrayOfData,
                                                 dynamicStack: ArrayOfData,
                                                 type: AbiParameterType,
                                                 offset: Int,
                                                 data: String) throws -> Int {
        
        //adding offset
        staticStack.array.append(BTCBigNumber(int64: Int64(offset)).unsignedBigEndian ?? placeholderData())
        let arrayElements = data.dynamicArrayElementsFromParameter()
        var lenght: Int = 0
        
        switch type {
            
        case .fixedArrayOfUint(let size):
            
            lenght = size
            
            //adding array elements count
            dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())
            
            for index in 0..<size {
                
                let element = arrayElements[safe: index]
                dynamicStack.array.append(BTCBigNumber(decimalString: element).unsignedBigEndian ?? placeholderData())
            }
        case .fixedArrayOfInt(let size):
            
            lenght = size
            
            //adding array elements count
            dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

            for index in 0..<size {
                
                let element = arrayElements[safe: index]
                dynamicStack.array.append(BTCBigNumber(decimalString: element).unsignedBigEndian ?? placeholderData())
            }
        case .fixedArrayOfBool(let size):
            
            lenght = size
            
            //adding array elements count
            dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

            for index in 0..<size {
                
                let element = arrayElements[safe: index]
                
                if element == "true" {
                    dynamicStack.array.append(BTCBigNumber(decimalString: "1").unsignedBigEndian ?? placeholderData())
                } else if element == "false" {
                    dynamicStack.array.append(BTCBigNumber(decimalString: "0").unsignedBigEndian ?? placeholderData())
                } else {
                    dynamicStack.array.append(BTCBigNumber(decimalString: element).unsignedBigEndian ?? placeholderData())
                }
            }
            
        case .fixedArrayOfAddresses(let size):
            
            lenght = size
            
            //adding array elements count
            dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

            for index in 0..<size {
                                
                if let element = arrayElements[safe: index],
                    var value = Base58.decode(element) as Data? {
                    
                    if value.count == 25 {
                        value = value.subdata(in: 1..<21)
                    }
                    
                    value = fillSlice(data: value)
                    dynamicStack.array.append(value)
                    
                } else {
                    dynamicStack.array.append(placeholderData())
                }
            }
            
        case .fixedArrayOfFixedBytes(let bytesSize, let arraySize):
            
            lenght = arraySize
            
            //adding array elements count
            dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

            for index in 0..<arraySize {
                
                let element = arrayElements[safe: index]
                
                if var value = element?.data(using: .ascii) {
                    
                    if value.count > bytesSize {
                        value = value.subdata(in: 0..<bytesSize)
                    }
                    
                    let fillData = Data(count: sliceSize - value.count)
                    value.append(fillData)
                    
                    dynamicStack.array.append(value)
                    
                } else {
                    dynamicStack.array.append(placeholderData())
                }
            }
        default:
            break
        }

        return offset + lenght * sliceSize + sliceSize
    }
    
    fileprivate func encodeDynamicStringArray(staticStack: ArrayOfData,
                                              dynamicStack: ArrayOfData,
                                              type: AbiParameterType,
                                              offset: Int,
                                              data: String) throws -> Int {
        //adding offset
        staticStack.array.append(BTCBigNumber(int64: Int64(offset)).unsignedBigEndian ?? placeholderData())
        
        //adding dynamic data in dynamic stack
        let arrayElements = data.dynamicArrayStringsFromParameter()
        let lenght = arrayElements.count
        
        //adding array elements count
        dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

        for index in 0..<arrayElements.count {
            
            let element = arrayElements[index]
            
            //adding dynamic data in dynamic stack
            let lenght = element.data(using: .utf8)?.count ?? 0
            
            dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())
            
            let stringData = dataMultiply32bit(string: element)
            dynamicStack.array.append(stringData ?? placeholderData())
        }
        
        return offset + lenght * sliceSize + sliceSize
    }
    
    fileprivate func encodeBytes(staticStack: ArrayOfData,
                                 dynamicStack: ArrayOfData,
                                 type: AbiParameterType,
                                 offset: Int,
                                 data: String) throws -> Int {
        
        //adding offset
        staticStack.array.append(BTCBigNumber(int64: Int64(offset)).unsignedBigEndian ?? placeholderData())
        
        //adding dynamic data in dynamic stack
        let lenght = data.data(using: .utf8)?.count ?? 0
        dynamicStack.array.append(BTCBigNumber(int64: Int64(lenght)).unsignedBigEndian ?? placeholderData())

        let stringData = dataMultiply32bit(string: data)
        dynamicStack.array.append(stringData ?? placeholderData())
        
        return offset + sliceSize + (stringData?.count ?? 0)
    }
    
    fileprivate func placeholderData() -> Data {
        let data = Data(count: sliceSize)
        return data
    }
    
    fileprivate func fillSlice(data: Data) -> Data {
        
        var filledData = Data(count: sliceSize - data.count)
        filledData.append(data)
        return filledData
    }
    
    fileprivate func dataMultiply32bit(string: String) -> Data? {
        
        if var data = string.data(using: .utf8) {
            var expectedLenght = data.count % sliceSize != 0 ? (data.count / sliceSize + 1) : data.count / sliceSize
            expectedLenght = expectedLenght == 0 ? 1 : expectedLenght
            let filledData = Data(count: sliceSize * expectedLenght - data.count)
            data.append(filledData)
            return data
        }
        return nil
    }
    
    fileprivate func counSlicesOfData(data: Data?) -> Int {
        
        if let data = data {
            return data.count % sliceSize == 0 ? data.count / sliceSize : data.count / sliceSize + 1
        }
        
        return 0
    }
}
