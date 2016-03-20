//
//  ViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

/// Represents a View in MVVM pattern.
public protocol ViewType
{
    /// ViewModel used in the receiver.
    var viewModel: ViewModelType! { get }
}

/// General reuse Identifier.
///
/// This may be used for UITableViewCell or similar.
let ViewModelIdentifier = "ViewModelIdentifier"
