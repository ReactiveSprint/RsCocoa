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
    
    /// Unified errors signal for the receiver.
    var errors: Signal<ViewModelErrorType, NoError> { get }
    
    /// Whether the receiver is currently loading
    var loading: AnyProperty<Bool> { get }
    
    /// Binds `errorSignal` to the receiver's `errors.`
    ///
    /// This method allows you to forward errors without binding an Action.
    ///
    /// - Parameter errorSignal: A signal which sends ViewModelErrorType
    func bindErrors<Error: ViewModelErrorType>(errorSignal: Signal<Error, NoError>)
    
    /// Binds 'loadingProducer` to the receiver's `loading.`
    ///
    /// - Parameter loadingProducer: A producer which sends `true` when loading and false otherwise.
    func bindLoading(loadingProducer: SignalProducer<Bool, NoError>)
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
        .skipRepeats()
        .filter({ $0 })
        .map({ [unowned self] _ in self })
    
    /// Observes the receiver's `active` property, and sends the receiver whenever it
    /// changes from true to false.
    ///
    /// If the receiver is currently inactive, this signal will send once immediately
    /// upon observe.
    private(set) public lazy var didBecomeInActive: SignalProducer<ViewModel, NoError> = self.active.producer
        .skipRepeats()
        .filter({ !$0 })
        .map({ [unowned self] _ in self })
    
    private let errorsObserver: Observer<Signal<ViewModelErrorType, NoError>, NoError>
    /// Unified errors signal for the receiver.
    ///
    /// Use `bindAction(Action)` or `bindErrors(Signal)`
    public let errors: Signal<ViewModelErrorType, NoError>
    
    private let loadingObserver: Observer<SignalProducer<Bool, NoError>, NoError>
    /// Whether the receiver is currently loading
    public let loading: AnyProperty<Bool>
    
    /// Initializes a ViewModel with `title`
    ///
    /// - Parameter title: Title to be used for the reciever.
    public init(title: String?)
    {
        self.title = ReactiveCocoa.MutableProperty(title)
        
        let errors: (Signal<Signal<ViewModelErrorType, NoError>, NoError>, Observer<Signal<ViewModelErrorType, NoError>, NoError>) = Signal.pipe()
        
        self.errors = errors.0.flatten(.Merge)
        errorsObserver = errors.1
        
        let (loadingProducers, loadingObserver) = SignalProducer<SignalProducer<Bool, NoError>, NoError>.buffer(0)
        
        self.loadingObserver = loadingObserver
        
        let startProducer = SignalProducer<Bool, NoError>(value: false)
        let loadingProducer = loadingProducers.scan(startProducer, { (producer, otherProducer) -> SignalProducer<Bool, NoError> in
            
            //always start otherProducer with false, so combineLatestWith will always work..
            return producer.combineLatestWith(SignalProducer(value: false).concat(otherProducer)).map { (a, b) in
                return a || b
            }
        }).flatten(.Latest)
        
        loading = AnyProperty(initialValue: false, producer: loadingProducer)
    }
    
    /// Initializes a ViewModel with `nil title`.
    public convenience init()
    {
        self.init(title: nil)
    }
    
    deinit
    {
        loadingObserver.sendCompleted()
        errorsObserver.sendCompleted()
    }
    
    /// Binds `errorSignal` to the receiver's `errors.`
    ///
    /// This method allows you to forward errors without binding an Action.
    /// All error signals are merged.
    ///
    /// - Parameter errorSignal: A signal which sends ViewModelErrorType
    public func bindErrors<Error: ViewModelErrorType>(errorSignal: Signal<Error, NoError>)
    {
        errorsObserver.sendNext(errorSignal.map { $0 as ViewModelErrorType })
    }
    
    /// Binds 'loadingProducer` to the receiver's `loading.`
    ///
    /// Loading signals are combined with `OR` operator.
    ///
    /// In other words, if any loading producer sends `true`
    /// then the receiver's `loading` property will send `true` as well.
    /// And only sends `false` when all loading signals send `false.`
    ///
    /// - Parameter loadingProducer: A producer which sends `true` when loading and false otherwise.
    public func bindLoading(loadingProducer: SignalProducer<Bool, NoError>)
    {
        loadingObserver.sendNext(loadingProducer)
    }
}

public extension ViewModelType
{
    /// Whether the receiver is currently enabled.
    ///
    /// This is the opposite of `loading`.
    ///
    /// Suitable to be used with `Action.enabledIf` if you want your Action
    /// to be enabled if the receiver is.
    public var enabled: AnyProperty<Bool> {
        return AnyProperty(initialValue: false, producer: loading.producer.map { !$0 })
    }
    
    /// Binds `action.errors` to the receiver's `errors` and `action.executing` to `loading.`
    public func bindAction<Input, Output, Error: ViewModelErrorType>(action: Action<Input, Output, Error>)
    {
        bindErrors(action.errors)
        bindLoading(action.executing.producer)
    }
    
    /// Binds `action.executing` to the receiver's `loading.`
    public func bindAction<Input, Output, Error: ErrorType>(action: Action<Input, Output, Error>)
    {
        bindLoading(action.executing.producer)
    }
    
    /// Binds 'loadingSignal` to the receiver's `loading.`
    ///
    /// - Parameter loadingSignal: A signal which sends `true` when loading and false otherwise.
    public func bindLoading(loadingSignal: Signal<Bool, NoError>)
    {
        bindLoading(SignalProducer(signal: loadingSignal))
    }
}

/// Represents Errors that occur in ViewModels.
///
/// This error type is suitable for use in Alerts.
public protocol ViewModelErrorType: ErrorType
{
    var localizedDescription: String { get }
    
    var localizedRecoverySuggestion: String? { get }
    
    var localizedRecoveryOptions: [String]? { get }
}

extension NSError: ViewModelErrorType
{
    
}
