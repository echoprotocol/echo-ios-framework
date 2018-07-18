//
//  Collection+Extension.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
