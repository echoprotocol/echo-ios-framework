//
//  ReslutHandler.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public typealias Completion<T> = (_ result: Result<T, ECHOError>) -> Void

/// An enum representing either a failure with an explanatory error, or a success with a result value.
public enum Result<T, Error: Swift.Error>: CustomStringConvertible, CustomDebugStringConvertible {
    case success(T)
    case failure(Error)
    
    // MARK: Constructors
    
    /// Constructs a success wrapping a `value`.
    public init(value: T) {
        self = .success(value)
    }
    
    /// Constructs a failure wrapping an `error`.
    public init(error: Error) {
        self = .failure(error)
    }
    
    /// Constructs a result from an `Optional`, failing with `Error` if `nil`.
    public init(_ value: T?, failWith: @autoclosure () -> Error) {
        self = value.map(Result.success) ?? .failure(failWith())
    }
    
    /// Constructs a result from a function that uses `throw`, failing with `Error` if throws.
    public init(_ function: @autoclosure () throws -> T) {
        self.init(attempt: function)
    }
    
    /// Constructs a result from a function that uses `throw`, failing with `Error` if throws.
    public init(attempt function: () throws -> T) {
        do {
            self = .success(try function())
        } catch var error {
            if Error.self == AnyError.self {
                error = AnyError(error)
            }
            // forece cast we need because Error is always Swift.Error
            // swiftlint:disable force_cast
            self = .failure(error as! Error)
            // swiftlint:enable force_cast
        }
    }
    
    // MARK: Deconstruction
    
    /// Returns the value from `success` Results or `throw`s the error.
    public func dematerialize() throws -> T {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
    
    /// Case analysis for Result.
    ///
    /// Returns the value produced by applying `ifFailure` to `failure` Results, or `ifSuccess` to `success` Results.
    public func analysis<Result>(ifSuccess: (T) -> Result, ifFailure: (Error) -> Result) -> Result {
        switch self {
        case let .success(value):
            return ifSuccess(value)
        case let .failure(value):
            return ifFailure(value)
        }
    }
    
    // MARK: Errors
    
    /// The domain for errors constructed by Result.
    public static var errorDomain: String { return "com.antitypical.Result" }
    
    /// The userInfo key for source functions in errors constructed by Result.
    public static var functionKey: String { return "\(errorDomain).function" }
    
    /// The userInfo key for source file paths in errors constructed by Result.
    public static var fileKey: String { return "\(errorDomain).file" }
    
    /// The userInfo key for source file line numbers in errors constructed by Result.
    public static var lineKey: String { return "\(errorDomain).line" }
    
    /// Constructs an error.
    public static func error(_ message: String? = nil, function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        var userInfo: [String: Any] = [
            functionKey: function,
            fileKey: file,
            lineKey: line
            ]
        
        if let message = message {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        
        return NSError(domain: errorDomain, code: 0, userInfo: userInfo)
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        return analysis(
            ifSuccess: { ".success(\($0))" },
            ifFailure: { ".failure(\($0))" })
    }
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        return description
    }
}
// MARK: - Errors

/// An “error” that is impossible to construct.
///
/// This can be used to describe `Result`s where failures will never
/// be generated. For example, `Result<Int, NoError>` describes a result that
/// contains an `Int`eger and is guaranteed never to be a `failure`.
public enum NoError: Swift.Error, Equatable {
    public static func == (lhs: NoError, rhs: NoError) -> Bool {
        return true
    }
}

/// A type-erased error which wraps an arbitrary error instance. This should be
/// useful for generic contexts.
public struct AnyError: Swift.Error {
    /// The underlying error.
    public let error: Swift.Error
    
    public init(_ error: Swift.Error) {
        if let anyError = error as? AnyError {
            self = anyError
        } else {
            self.error = error
        }
    }
}

extension AnyError: CustomStringConvertible {
    public var description: String {
        return String(describing: error)
    }
}
