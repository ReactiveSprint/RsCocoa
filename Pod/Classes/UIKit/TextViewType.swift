//
//  TextViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 6/16/16.
//
//

import Foundation

/// Represents a TextView
///
/// Extension implementation available for `UILabel`, `UITextField` and `UITextView`
@objc public protocol TextViewType {
    /// Gets or sets text value for the receiver.
    ///
    /// Since some views have their property defined as `String!` not `String?`
    /// such as `UITextView`, this property is named `rs_text` instead of `text`
    /// Thus, this property must be implemented for your view.
    var rs_text: String? { get set }
    
    /// Gets or sets `hidden` value of the receiver.
    ///
    /// This is implemented by default for any `UIView`.
    var hidden: Bool { @objc(isHidden) get set }
}

extension UILabel: TextViewType {
    public var rs_text: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }
}

extension UITextField: TextViewType {
    public var rs_text: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }
}

extension UITextView: TextViewType {
    public var rs_text: String? {
        get {
            return text
        }
        set {
            if let value = newValue {
                text = value
            } else {
                text = ""
            }
        }
    }
}
