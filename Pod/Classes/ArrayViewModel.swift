//
//  ArrayViewModel.swift
//  Pods
//
//  Created by Ahmad Baraka on 2/28/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// Represents an ViewModel which wraps an Array of ViewModels of type `Element`
public protocol ArrayViewModelType: ViewModelType
{
    /// Type of ViewModels Array
    typealias Element: ViewModel
    
    /// Returns an Array of `Elements.`
    ///
    /// This Property could be implemented as a computed or a stored property.
    var viewModels: [Element] { get }
    
    /// Returns count of ViewModels.
    var count: AnyProperty<Int> { get }
    
    /// Returns localized message to be used when the array is empty.
    var localizedEmptyMessage: MutableProperty<String?> { get }
    
    /// Access the indexth element.
    ///
    /// - Parameter index: Must be > 0 and < count.
    subscript(index: Int) -> Element { get }
}

public extension ArrayViewModelType
{
    /// Returns true if Array is empty, false otherwise.
    public var isEmpty: AnyProperty<Bool> {
        return AnyProperty(initialValue: count.value <= 0, producer: count.producer.map { $0 <= 0 })
    }
}

/// ViewModel that has a Constant array of ViewModels.
public class ArrayViewModel<Element: ViewModel>: ViewModel, ArrayViewModelType
{
    /// Returns count of ViewModels.
    public let count: AnyProperty<Int>
    
    /// Returns an Array of `Elements.`
    public let viewModels: [Element]
    
    /// Returns localized message to be used when the array is empty.
    public let localizedEmptyMessage = MutableProperty<String?>(nil)
    
    /// Initializes ArrayViewModel with array of Element.
    public init(_ viewModels: [Element])
    {
        self.viewModels = viewModels
        count = AnyProperty(initialValue: viewModels.count, producer: SignalProducer.empty)
    }
    
    /// Initializes ArrayViewModel with array of Element and title.
    public convenience init(_ viewModels: [Element], title: String?)
    {
        self.init(viewModels)
        self.title.value = title
    }
    
    /// Initializes ArrayViewModel with array of Element, title and localizedEmptyMessage.
    public convenience init(_ viewModels: [Element], title: String?, localizedEmptyMessage: String?)
    {
        self.init(viewModels, title: title)
        self.localizedEmptyMessage.value = localizedEmptyMessage
    }
    
    /// Access the indexth element.
    ///
    /// - Parameter index: Must be > 0 and < count.
    public subscript(index: Int) -> Element { return viewModels[index] }
}
