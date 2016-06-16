//
//  ViewModelErrorType.swift
//  Pods
//
//  Created by Ahmad Baraka on 6/16/16.
//
//

import Foundation

/// Represents Errors that occur in ViewModels.
///
/// This error type is suitable for use in Alerts.
public protocol ViewModelErrorType: ErrorType {
    var localizedDescription: String { get }
    
    var localizedRecoverySuggestion: String? { get }
    
    var localizedRecoveryOptions: [String]? { get }
}

extension NSError: ViewModelErrorType {
    
}
