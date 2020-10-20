//
//  Errors.swift
//  Social
//
//  Created by Nikita Evstigneev on 11/09/2020.
//

import Foundation

public enum NetworkingError: LocalizedError {
    case deviceIsOffline
    case unauthorized
    case resourceNotFound
    case serverError(Error)
    case missingData
    case decodingFailed(Error)
}

public enum ErrorCategory {
    case nonRetryable
    case retryable
    case requiresLogout
}

public protocol CategorizedError: Error {
    var category: ErrorCategory { get }
}

public protocol UserFriendlyAlertSupportingError: Error {
    var alertTitle: String? { get }
}

extension NetworkingError: CategorizedError {
    public var category: ErrorCategory {
        switch self {
        case .deviceIsOffline, .serverError:
            return .retryable
        case .resourceNotFound, .missingData, .decodingFailed:
            return .nonRetryable
        case .unauthorized:
            return .requiresLogout
        }
    }
}

public extension Error {
    func resolveCategory() -> ErrorCategory {
        guard let categorized = self as? CategorizedError else {
            // We could optionally choose to trigger an assertion
            // here, if we consider it important that all of our
            // errors have categories assigned to them.
            return .nonRetryable
        }

        return categorized.category
    }
}
