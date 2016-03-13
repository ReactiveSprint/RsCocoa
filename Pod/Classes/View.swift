//
//  View.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

/// Represents a View in MVVM pattern.
public protocol View
{
    /// Type of `ViewModel`
    typealias ViewModel: ViewModelType
    
    var viewModel: ViewModel! { get }
}
