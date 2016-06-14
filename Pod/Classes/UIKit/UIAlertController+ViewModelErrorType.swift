//
//  UIAlertController+ViewModelErrorType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation

public extension UIAlertController {
    /// Initializes an instance with error.
    public convenience init(error: ViewModelErrorType) {
        self.init(title: error.localizedDescription,
                  message: error.localizedRecoverySuggestion,
                  preferredStyle: .Alert)
        
        //TODO: Properly add and handle recovery options..
        if let recoveryOptions = error.localizedRecoveryOptions {
            for option in recoveryOptions {
                let action = UIAlertAction(title: option, style: .Default, handler: nil)
                
                addAction(action)
            }
        }
    }
}
