//
//  ArrayViewModel.swift
//  Pods
//
//  Created by Ahmad Baraka on 2/28/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveCocoa
import Result

/// Non-generic ArrayViewModelType used with Cocoa.
public protocol CocoaArrayViewModelType: ViewModelType {
    /// Returns count of ViewModels.
    var count: AnyProperty<Int> { get }
    
    /// Returns true if Array is empty, false otherwise.
    var isEmpty: AnyProperty<Bool> { get }
    
    /// Returns localized message to be used when the array is empty.
    var localizedEmptyMessage: MutableProperty<String?> { get }
    
    /// Access the indexth element.
    ///
    /// - Parameter index: Must be > 0 and < count.
    subscript(index: Int) -> ViewModelType { get }
    
    /// Returns the first index where `predicate` returns `true` for the
    /// corresponding value, or `nil` if such value is not found.
    func indexOf(predicate: ViewModelType -> Bool) -> Int?
}

/// Represents an ViewModel which wraps an Array of ViewModels of type `Element`
public protocol ArrayViewModelType: CocoaArrayViewModelType {
    /// Type of ViewModels Array
    associatedtype Element: ViewModelType
    
    /// Returns an Array of `Elements.`
    ///
    /// This Property could be implemented as a computed or a stored property.
    var viewModels: [Element] { get }
    
    /// Access the indexth element.
    ///
    /// - Parameter index: Must be > 0 and < count.
    subscript(index: Int) -> Element { get }
    
    /// Returns the first index where `predicate` returns `true` for the
    /// corresponding value, or `nil` if such value is not found.
    func indexOf(predicate: Element -> Bool) -> Int?
}

public extension ArrayViewModelType {
    public subscript(index: Int) -> ViewModelType { return self[index] }
    
    public func indexOf(predicate: ViewModelType -> Bool) -> Int? {
        return indexOf { predicate($0) }
    }
}

public extension ArrayViewModelType where Self.Element: Equatable {
    /// Returns the first index where `value` equals `element` or `nil`
    /// `value` is not found.
    public func indexOf(element: Element) -> Int? {
        return indexOf { $0 == element }
    }
}

/// ViewModel that has a Constant array of ViewModels.
public class ArrayViewModel<Element: ViewModelType>: ViewModel, ArrayViewModelType {
    public let count: AnyProperty<Int>
    
    private(set) public lazy var isEmpty: AnyProperty<Bool> = AnyProperty(initialValue: self.count.value <= 0, producer: self.count.producer.map { $0 <= 0 })
    
    public let viewModels: [Element]
    
    private(set) public lazy var localizedEmptyMessage = MutableProperty<String?>(nil)
    
    /// Initializes ArrayViewModel with array of Element.
    public init(_ viewModels: [Element]) {
        self.viewModels = viewModels
        count = AnyProperty(initialValue: viewModels.count, producer: SignalProducer.empty)
    }
    
    public subscript(index: Int) -> Element { return viewModels[index] }
    
    public func indexOf(predicate: Element -> Bool) -> Int? {
        return viewModels.indexOf(predicate)
    }
}
