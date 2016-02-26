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
    
    /// Whether the view model is currently "active."
    ///
    /// This generally implies that the associated view is visible. When set to false,
    /// the view model should throttle or cancel low-priority or UI-related work.
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
    public func forwardWhileActive(viewModel: ViewModel) -> SignalProducer<Value, Error>
    {
        let activeProducer = viewModel.active.producer
        var signalDisposable: Disposable?
        var signalDisposableHandler: CompositeDisposable.DisposableHandle?
        
        return SignalProducer { (observer, disposable) -> () in
            disposable += activeProducer.start(Observer(failed: nil
                , completed: { observer.sendCompleted() },
                interrupted: { observer.sendInterrupted() },
                next: { isActive -> () in
                    if isActive
                    {
                        signalDisposable = self.start(Observer(failed: { observer.sendFailed($0) },
                            completed: nil,
                            interrupted: nil,
                            next: { observer.sendNext($0)}
                            ))
                        
                        signalDisposableHandler = disposable.addDisposable(signalDisposable)
                    }
                    else
                    {
                        if let signalDisposable1 = signalDisposable
                        {
                            signalDisposable1.dispose()
                            signalDisposable = nil
                        }
                        
                        if let signalDisposableHandler1 = signalDisposableHandler
                        {
                            signalDisposableHandler1.remove()
                            signalDisposableHandler = nil
                        }
                    }
            }))
        }
    }
}