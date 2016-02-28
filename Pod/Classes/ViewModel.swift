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

/// Represents a ViewModel.
public protocol ViewModelType
{
    /// Used as general `title`
    var title: ReactiveCocoa.MutableProperty<String?> { get }
    
    /// Whether the view model is currently "active."
    var active: MutableProperty<Bool> { get }
}

/// Abstract implementation of `ViewModel` used in `MVVM pattern`
public class ViewModel: ViewModelType
{
    /// Used as general `title`
    public let title: ReactiveCocoa.MutableProperty<String?>
    
    /// Whether the view model is currently "active."
    ///
    /// This generally implies that the associated view is visible. When set to false,
    /// the view model should throttle or cancel low-priority or UI-related work.
    ///
    /// Original `active` implementation and tests from
    /// [ReactiveViewModel.](https://github.com/ReactiveCocoa/ReactiveViewModel)
    ///
    /// This property defaults to false.
    public let active = ReactiveCocoa.MutableProperty(false)
    
    /// Observes the receiver's `active` property, and sends the receiver whenever it
    /// changes from false to true.
    ///
    /// If the receiver is currently active, this signal will send once immediately
    /// upon observe.
    private(set) public lazy var didBecomeActive: SignalProducer<ViewModel, NoError> = self.active.producer
        .skipRepeats({ $0 == $1 })
        .filter({ $0 })
        .map({ [unowned self] _ in self })
    
    /// Observes the receiver's `active` property, and sends the receiver whenever it
    /// changes from true to false.
    ///
    /// If the receiver is currently inactive, this signal will send once immediately
    /// upon observe.
    private(set) public lazy var didBecomeInActive: SignalProducer<ViewModel, NoError> = self.active.producer
        .skipRepeats({ $0 == $1 })
        .filter({ !$0 })
        .map({ [unowned self] _ in self })
    
    /// Initializes a ViewModel with `title`
    ///
    /// - Parameter title: Title to be used for the reciever.
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

public extension SignalProducerType
{
    /// Starts the receiver whenever `viewModel` is active.
    ///
    /// When `viewModel` is inactive, any active observer is disposed.
    ///
    /// - Returns: A SignalProducer starts and forwards `next`s from the latest observer
    /// and completes when `viewModel` is deinitialized. If the receiver sends
    /// an error at any point, the returned signal will error out as well.
    public func forwardWhileActive(viewModel: ViewModelType) -> SignalProducer<Value, Error>
    {
        return forwardWhileActive(viewModel.active.producer)
    }
    
    /// Throttles events on the receiver while `viewModel` is inactive.
    ///
    /// This method will stay subscribed to the receiver the entire time
    /// except that its events will be throttled when `viewModel`  becomes inactive.
    ///
    /// - Returns: A signal which forwards events from the receiver (throttled while
    /// `viewModel` is inactive), and completes when the receiver completes or `viewModel`
    /// is deinitialized.
    public func throttleWhileInactive(viewModel: ViewModelType, interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType) -> SignalProducer<Value, Error>
    {
        return throttleWhileInactive(viewModel.active.producer, interval: interval, onScheduler: scheduler)
    }
}

public extension SignalType
{
    /// Observes the receiver whenever `viewModel` is active.
    ///
    /// When `viewModel` is inactive, any active observer is disposed.
    ///
    /// - Returns: A signal which forwards `next`s from the latest observer
    /// and completes when `viewModel` is deinitialized. If the receiver sends
    /// an error at any point, the returned signal will error out as well.
    public func forwardWhileActive(viewModel: ViewModelType) -> Signal<Value, Error>
    {
        return forwardWhileActive(viewModel.active.producer)
    }
    
    /// Throttles events on the receiver while `viewModel` is inactive.
    ///
    /// This method will stay subscribed to the receiver the entire time
    /// except that its events will be throttled when `viewModel`  becomes inactive.
    ///
    /// - Returns: A signal which forwards events from the receiver (throttled while
    /// `viewModel` is inactive), and completes when the receiver completes or `viewModel`
    /// is deinitialized.
    public func throttleWhileInactive(viewModel: ViewModelType, interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType) -> Signal<Value, Error>
    {
        return throttleWhileInactive(viewModel.active.producer, interval: interval, onScheduler: scheduler)
    }
}
