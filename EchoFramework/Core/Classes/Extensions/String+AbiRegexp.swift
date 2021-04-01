//
//  String+AbiRegexp.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

extension String {
    
    func isUint() -> Bool {
        let pattern = "(uint[0-9]{0,3})$"
        return isMatchString(pattern: pattern)
    }
    
    func isInt() -> Bool {
        
        let pattern = "(int[0-9]{0,3})$"
        return isMatchString(pattern: pattern)
    }
    
    func isBool() -> Bool {
        return self == "bool"
    }
    
    func isBytes() -> Bool {
        let pattern = "(bytes)$"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedBytes() -> Bool {
        let pattern = "(bytes[0-9]{1,3})$"
        return isMatchString(pattern: pattern)
    }
    
    func isArray() -> Bool {
        let pattern = "^([a-zA-Z]\\w+\\[[0-9]{0,}\\])$"
        return isMatchString(pattern: pattern)
    }
    
    func isArrayOfArrays() -> Bool {
        let pattern = "\\b([a-zA-Z]{1,}.{0,}\\[[1-9]{1,}[0-9]{0,}\\]\\[\\])$"
        return isMatchString(pattern: pattern)
    }
    
    func isAddress() -> Bool {
        return self == "address"
    }
    
    func isString() -> Bool {
        return self == "string"
    }
    
    func isFixedArrayOfString() -> Bool {
        return self == "string[]"
    }
    
    func isDynamicArrayOfString() -> Bool {
        let pattern = "(string\\[[0-9]{0,0}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedArrayOfUint() -> Bool {
        let pattern = "(uint[0-9]{0,3}\\[[0-9]{1,}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isDynamicArrayOfUint() -> Bool {
        let pattern = "(uint[0-9]{0,3}\\[[0-9]{0,0}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedArrayOfInt() -> Bool {
        let pattern = "(int[0-9]{0,3}\\[[0-9]{1,}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isDynamicArrayOfInt() -> Bool {
        let pattern = "(int[0-9]{0,3}\\[[0-9]{0,0}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedArrayOfBool() -> Bool {
        let pattern = "(bool\\[[0-9]{1,}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isDynamicArrayOfBool() -> Bool {
        let pattern = "(bool\\[[0-9]{0,0}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedArrayOfBytes() -> Bool {
        return self == "bytes[]"
    }
    
    func isDynamicArrayOfBytes() -> Bool {
        let pattern = "(bytes\\[[0-9]{0,0}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedArrayOfAddresses() -> Bool {
        return self == "address[]"
    }
    
    func isDynamicArrayOfAddresses() -> Bool {
        let pattern = "(address\\[[0-9]{0,0}\\]$)"
        return isMatchString(pattern: pattern)
    }
    
    func isFixedArrayOfFixedBytes() -> Bool {
        let pattern = "(bytes[0-9]{1,3}\\[[0-9]{1,}])$"
        return isMatchString(pattern: pattern)
    }
    
    func isDynamicArrayOfFixedBytes() -> Bool {
        let pattern = "(bytes[0-9]{1,3}\\[[0-9]{0,0}])$"
        return isMatchString(pattern: pattern)
    }
    
    func arraySize() -> Int {
        let pattern = "(bytes[0-9]{1,3}\\[[0-9]{0,0}])$"
        let match = self.matchedString(pattern: pattern)
        return Int(match) ?? 0
    }
    
    func fixedBytesSize() -> Int {
        
        let pattern = "([0-9]{1,})"
        let match = self .matchedString(pattern: pattern)
        
        return Int(match) ?? 0
    }
    
    func uintSize() -> Int {
        let pattern = "([0-9]{1,})"
        let match = self .matchedString(pattern: pattern)
        return Int(match) ?? 256
    }
    
    func intSize() -> Int {
        let pattern = "([0-9]{1,})"
        let match = self .matchedString(pattern: pattern)
        return Int(match) ?? 256
    }
    
    func isMatchString(pattern: String) -> Bool {
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let muchNumber = regex.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count))
            return muchNumber > 0
        } else {
            return false
        }
    }
    
    fileprivate func matchedString(pattern: String) -> String {
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = regex.rangeOfFirstMatch(in: self, options: [], range: NSMakeRange(0, self.count))
            
            if range.location != NSNotFound {
                
                let indexStartOfText = self.index(self.startIndex, offsetBy: range.location)
                let indexEndOfText = self.index(indexStartOfText, offsetBy: range.length)
                return String(self[indexStartOfText..<indexEndOfText])
            }
        }
        return ""
    }
    
    fileprivate func stringFromBracer(string: String) -> String {
        return string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
    }
    
    func dynamicArrayElementsFromParameter() -> [String] {
        
        let paramsWithoutBracers = stringFromBracer(string: self)
        return paramsWithoutBracers.components(separatedBy: ",")
    }
    
    func dynamicArrayStringsFromParameter() -> [String] {
        
        let paramsWithoutBracers = stringFromBracer(string: self)
        var matches = [String]()
        let pattern = "\"(\\.|[^\"])*\""
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            let ranges = regex.matches(in: paramsWithoutBracers, options: [], range: NSMakeRange(0, paramsWithoutBracers.count))
            
            ranges.forEach { (checkingRange) in
                
                let indexStartOfText = self.index(paramsWithoutBracers.startIndex, offsetBy: checkingRange.range.location + 1)
                let indexEndOfText = self.index(indexStartOfText, offsetBy: checkingRange.range.length - 2)
                
                matches.append(String(paramsWithoutBracers[indexStartOfText..<indexEndOfText]))
            }
        }
        
        return matches
    }

}
