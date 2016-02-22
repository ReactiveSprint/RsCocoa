//
//  ViewModel.swift
//  Pods
//
//  Created by Ahmad Baraka on 2/22/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// Abstract implementation of `ViewModel` used in `MVVM pattern`
public class ViewModel
{
    /// Used as general `title`
    public let title: ReactiveCocoa.MutableProperty<String?>
    
    /// Initializes a ViewModel with `title`
    ///
    /// - parameter title: Title to be used for the reciever.
    public init(title: String?)
    {
        self.title = ReactiveCocoa.MutableProperty(title)
    }
    /// Initializes a ViewModel with `nil title`.
    public convenience init()
    {
        self.init(title: nil)
    }
}