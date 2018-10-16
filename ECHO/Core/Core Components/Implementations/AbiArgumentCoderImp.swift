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
    
    public func getValueTypes(data: Data, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel] {
        
        return try decodeOutputs(data: data, function: abiFunc)
    }
    
    public func getValueTypes(string: String, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel] {
        
        if let data = Data(hex: string) {
            return try decodeOutputs(data: data, function: abiFunc)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
}

// swiftlint:disable no_fallthrough_only
private typealias Decoder = AbiArgumentCoderImp
extension Decoder {
    
    fileprivate func decodeOutputs(data: Data, function: AbiFunctionModel) throws -> [AbiTypeValueOutputModel] {
        
        guard data.count > 0 else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
        
        var decodedOutputs = [AbiTypeValueOutputModel]()
        var outputsData = data
        
        for index in 0..<function.outputs.count {
            
            let type = function.outputs[index].type
            
            switch type {
            case .uint(_): fallthrough
            case .int(_): fallthrough
            case .bool:
                
                if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: 0..<sliceSize)) {
                    
                    let start = 0
                    let end = start + sliceSize
                    
                    if let newData = outputsData[safe: start..<end] {
                        let output = AbiTypeValueOutputModel(type: type, value: btcNumber.decimalString)
                        decodedOutputs.append(output)
                        outputsData = newData
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: nil)
                        throw error
                    }
                }
            case .string:
                
                if let offset = BTCBigNumber(unsignedBigEndian: outputsData[safe: 0..<sliceSize] ),
                    let lenght = BTCBigNumber(unsignedBigEndian: outputsData[safe: sliceSize..<(sliceSize * 2)]) {
                    
                    let data = outputsData[safe: (sliceSize + Int(offset.uint32value))..<(sliceSize * 2) + Int(lenght.uint32value)]

                    if let sringOutput = stringFrom(data: data) {
                        let start = sliceSize * 2 + (counSlicesOfData(data: data) * sliceSize)
                        let end = outputsData.count
                        
                        if let newData = outputsData[safe: start..<end] {
                            let output = AbiTypeValueOutputModel(type: type, value: sringOutput)
                            decodedOutputs.append(output)
                            outputsData = newData
                        } else {
                            let error = NSError(domain: "", code: 0, userInfo: nil)
                            throw error
                        }
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: nil)
                        throw error
                    }
                }
            case .address: fallthrough
            case .fixedBytes(_):
                
                var stringOutput = stringFrom(data: outputsData.subdata(in: 0..<sliceSize))
                
                if stringOutput == nil {
                    stringOutput = outputsData.subdata(in: 0..<sliceSize).hex
                }
                
                if let stringOutput = stringOutput {
                
                    let start = sliceSize
                    let end = outputsData.count

                    if let newData = outputsData[safe: start..<end] {
                        let output = AbiTypeValueOutputModel(type: type, value: stringOutput)
                        decodedOutputs.append(output)

                        outputsData = newData
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: nil)
                        throw error
                    }
                }
            case .fixedArrayOfAddresses(let size):
                var addresses = [String]()
                for index in 0..<size {
                    if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: (sliceSize * index)..<(sliceSize * index + sliceSize))) {
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
            case .fixedArrayOfBool(let size):
                var bools = [Bool]()
                for index in 0..<size {
                    if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: (sliceSize * index)..<(sliceSize * index + sliceSize))),
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
            case .fixedArrayOfInt(let size), .fixedArrayOfUint(let size):
                var ints = [Int]()
                for index in 0..<size {
                    if let btcNumber = BTCBigNumber(unsignedBigEndian: outputsData.subdata(in: (sliceSize * index)..<(sliceSize * index + sliceSize))),
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
            
        case .uint(_): fallthrough
        case .int(_):
            
            staticStack.array.append(BTCBigNumber(decimalString: data).unsignedBigEndian ?? placeholderData())
        case .bool:
            
            if data == "true" {
                staticStack.array.append(BTCBigNumber(decimalString: "1").unsignedBigEndian ?? placeholderData())
            } else if data == "false" {
                staticStack.array.append(BTCBigNumber(decimalString: "0").unsignedBigEndian ?? placeholderData())
            } else {
                staticStack.array.append(BTCBigNumber(decimalString: data).unsignedBigEndian ?? placeholderData())
            }
            
        case .address:
            
            if var value = Base58.decode(data) as Data? {
                
                if value.count == 25 {
                    value = value.subdata(in: 1..<21)
                }
                
                value = fillSlice(data: value)
                staticStack.array.append(value)

            } else {
                staticStack.array.append(placeholderData())
            }
            
        case .fixedBytes(let size):
            
            if var value = Data(hex: data) {
                
                if value.count > size {
                    value = value.subdata(in: 0..<size)
                }
                
                let fillData = Data(count: sliceSize - value.count)
                value.append(fillData)
                
                staticStack.array.append(value)

            } else {
                staticStack.array.append(placeholderData())
            }

        default:
            break
        }
    }
    
    fileprivate func encodeAddress(staticStack: ArrayOfData, type: AbiParameterType, offset: Int, data: String) throws {
        
        if var value = Base58.decode(data) as Data? {
            
            if value.count == 25 {
                value = value.subdata(in: 1..<21)
            }
            
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
        case .dynamicArrayOfInt: fallthrough
        case .dynamicArrayOfUint:
            
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
// swiftlint:enable no_fallthrough_only
