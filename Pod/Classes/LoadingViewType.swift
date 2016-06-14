//
//  LoadingViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation

/// Represents a View that displays loading state.
@objc public protocol LoadingViewType {
    /// Gets or sets whether the receiver is loading.
    var loading: Bool { get set }
}
