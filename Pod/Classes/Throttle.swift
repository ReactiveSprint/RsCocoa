//
//  Throttle.swift
//  Pods
//
//  Created by Ahmad Baraka on 2/28/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public extension SignalProducerType
{
    /// Starts the receiver whenever `activeProducer` sends `true.`
    ///
    /// When `activeProducer` sends false, any active observer is disposed.
    ///
    /// - Returns: A SignalProducer starts and forwards `next`s from the latest observer
    /// and completes when `activeProducer` completes. If the receiver sends
    /// an error at any point, the returned signal will error out as well.
    public func forwardWhileActive(activeProducer: SignalProducer<Bool, NoError>) -> SignalProducer<Value, Error>
    {
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
    
    /// Throttles events on the receiver while `activeProducer` sends `false.`
    ///
    /// This method will stay subscribed to the receiver the entire time
    /// except that its events will be throttled when `activeProducer`  sends false.
    ///
    /// - Returns: A signal which forwards events from the receiver (throttled while
    /// `activeProducer` sends false), and completes when the receiver completes or `activeProducer`
    /// completes.
    public func throttleWhileInactive(activeProducer: SignalProducer<Bool, NoError>, interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType) -> SignalProducer<Value, Error>
    {
        let activeProducer = activeProducer.promoteErrors(Error)
        let untilSignal = flatMap(.Latest, transform: { _ in SignalProducer.empty })
            .flatMapError({ _ in SignalProducer<(), NoError>.empty})
        let producer = self.producer.replayLazily(1)
        
        return SignalProducer <SignalProducer<Value, Error>, Error> ({ (observer, disposable) in
            disposable += activeProducer.start { event in
                switch event
                {
                case let .Failed(error):
                    observer.sendFailed(error)
                case .Completed:
                    observer.sendCompleted()
                case .Interrupted:
                    observer.sendInterrupted()
                case let .Next(active):
                    if active
                    {
                        observer.sendNext(producer)
                    }
                    else
                    {
                        observer.sendNext(producer.throttle(interval, onScheduler: scheduler))
                    }
                    break
                }
            }
        }).flatten(.Latest)
            .takeUntil(untilSignal)
    }
}

public extension SignalType
{
    /// Observes the receiver whenever `activeProducer` sends `true.`
    ///
    /// When `activeProducer` sends false, any active observer is disposed.
    ///
    /// - Returns: A signal which forwards `next`s from the latest observer
    /// and completes when `activeProducer` completes. If the receiver sends
    /// an error at any point, the returned signal will error out as well.
    public func forwardWhileActive(activeProducer: SignalProducer<Bool, NoError>) -> Signal<Value, Error>
    {
        let signal = self.signal
        
        return Signal { observer -> (Disposable?) in
            let disposable = CompositeDisposable()
            var signalDisposable: Disposable?
            var signalDisposableHandler: CompositeDisposable.DisposableHandle?
            
            disposable += activeProducer.start(
                Observer(failed: nil,
                    completed: { observer.sendCompleted() },
                    interrupted: { observer.sendInterrupted() },
                    next:
                    { isActive -> () in
                        if isActive
                        {
                            signalDisposable = signal.observe(
                                Observer(failed: { observer.sendFailed($0) },
                                    completed: nil,
                                    interrupted: nil,
                                    next: { observer.sendNext($0)})
                            )
                            
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
            
            return disposable
        }
    }
    
    /// Throttles events on the receiver while `activeProducer` sends `false.`
    ///
    /// This method will stay subscribed to the receiver the entire time
    /// except that its events will be throttled when `activeProducer` sends `false.`
    ///
    /// - Returns: A signal which forwards events from the receiver (throttled while
    /// `activeProducer` sends false), and completes when the receiver completes or `activeProducer`
    /// copmletes.
    public func throttleWhileInactive(activeProducer: SignalProducer<Bool, NoError>, interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType) -> Signal<Value, Error>
    {
        var r: Signal<Value, Error>!
        SignalProducer(signal: self)
            .throttleWhileInactive(activeProducer, interval: interval, onScheduler: scheduler)
            .startWithSignal { (signal, disposable) -> () in
                r = signal
        }
        return r
    }
}
