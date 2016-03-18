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
public protocol _ArrayViewModelType: ViewModelType
{
    /// Returns count of ViewModels.
    var count: AnyProperty<Int> { get }
    
    /// Returns localized message to be used when the array is empty.
    var localizedEmptyMessage: MutableProperty<String?> { get }
}

/// Represents an ViewModel which wraps an Array of ViewModels of type `Element`
public protocol ArrayViewModelType: _ArrayViewModelType
{
    /// Type of ViewModels Array
    typealias Element: ViewModelType
    
    /// Returns an Array of `Elements.`
    ///
    /// This Property could be implemented as a computed or a stored property.
    var viewModels: [Element] { get }
    
    /// Access the indexth element.
    ///
    /// - Parameter index: Must be > 0 and < count.
    subscript(index: Int) -> Element { get }
}

public extension _ArrayViewModelType
{
    /// Returns true if Array is empty, false otherwise.
    public var isEmpty: AnyProperty<Bool> {
        return AnyProperty(initialValue: count.value <= 0, producer: count.producer.map { $0 <= 0 })
    }
}

/// ViewModel that has a Constant array of ViewModels.
public class ArrayViewModel<Element: ViewModelType>: ViewModel, ArrayViewModelType
{
    public let count: AnyProperty<Int>
    
    public let viewModels: [Element]
    
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
    
    public subscript(index: Int) -> Element { return viewModels[index] }
}

//public class CocoaArrayViewModel: NSObject, _ArrayViewModelType
//{
//    public let count: AnyProperty<Int>
//    
//    private let _viewModels: () -> [AnyObject]
//    public var viewModels: [AnyObject] {
//        return _viewModels()
//    }
//    
//    public let localizedEmptyMessage: MutableProperty<String?>
//    
//    private let _subscript: (Int) -> AnyObject
//    
//    public init<ArrayViewModel: ArrayViewModelType>(_ viewModel: ArrayViewModel)
//    {
//        _viewModels = { _ in
//            return viewModel.viewModels
//        }
//        
//        count = viewModel.count
//        
//        localizedEmptyMessage = viewModel.localizedEmptyMessage
//        
//        _subscript = { viewModel[$0] }
//    }
//    
//    public subscript(index: Int) -> AnyObject { return _subscript(index) }
//}
