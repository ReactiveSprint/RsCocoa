//
//  ViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public extension UIViewController
{
    /// Binds ViewModel's `active` property from the receiver.
    ///
    /// When `viewDidAppear` is called or `UIApplicationDidBecomeActiveNotification` is sent
    /// ViewModel's active is set to `true.`
    ///
    /// When `viewWillDisappear` is called or `UIApplicationWillResignActiveNotification` is sent
    /// ViewModel's active is set to `false.`
    public func bindActive(viewModel: ViewModelType)
    {
        let presented = RACSignal.merge([
            rac_signalForSelector(Selector("viewDidAppear")).mapReplace(true)
            , rac_signalForSelector(Selector("viewWillDisappear")).mapReplace(false)
            ])
        
        let appActive = RACSignal.merge([
            NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
                .mapReplace(true)
            , NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationWillResignActiveNotification, object: nil)
                .mapReplace(false)
            ]).startWith(true)
        
        let activeSignal = RACSignal.combineLatest([presented, appActive])
            .and()
            .toSignalProducer()
            .map { $0 as! Bool }
            .flatMapError { _ in SignalProducer<Bool, NoError>.empty }
        
        viewModel.active <~ activeSignal
    }
}

/// ViewController which wraps `ViewModel`.
public class ViewController<ViewModel: ViewModelType>: UIViewController, View
{
    /// ViewModel which will be used as context for this `View.`
    ///
    /// This property is expected to be set only once with a non-nil value.
    public var viewModel: ViewModel! {
        didSet {
            precondition(oldValue == nil)
            bindViewModel(viewModel)
        }
    }
    
    /// Used to bind viewModel's title.
    private lazy var titleProperty: DynamicProperty = DynamicProperty(object: self, keyPath: "title")

    /// Binds `viewModel` to the receiver.
    ///
    /// This is called at `didSet` for viewModel property.
    ///
    /// Default implementation calls `bindActive(_:)` , `bindTitle(_:)`, `bindLoading(_:)`
    /// and `bindErrors(_:)`
    ///
    /// - Parameter viewModel: A ViewModel to be bound to the receiver.
    public func bindViewModel(viewModel: ViewModel)
    {
        bindActive(viewModel)
        bindTitle(viewModel)
        bindLoading(viewModel)
        bindErrors(viewModel)
    }
    
    /// Binds viewModel's title to the receiver title.
    public func bindTitle(viewModel: ViewModel)
    {
        titleProperty <~ viewModel.title.producer.map { $0 as AnyObject? }
    }
    
    /// Binds viewModel's loading to `showLoading(_:)`
    public func bindLoading(viewModel: ViewModel)
    {
        // Make sure it always emits false when completed
        let loadingProducer = viewModel.loading.producer.concat(SignalProducer(value: false))
        loadingProducer.startWithNext(self.presentLoading)
    }
    
    /// Shows or hides loading view.
    ///
    /// Default implementation does nothing.
    public func presentLoading(loading: Bool)
    {
        
    }
    
    /// Binds viewModel's errors to `showErrors(_:)`
    public func bindErrors(viewModel: ViewModel)
    {
        viewModel.errors.observeNext(self.presentError)
    }
    
    /// Presents `error` in an Alert View.
    public func presentError(error: ViewModelErrorType)
    {
        let alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: .Alert)
        
        //TODO: Properly add and handle recovery options..
        if let recoveryOptions = error.localizedRecoveryOptions
        {
            for option in recoveryOptions
            {
                let action = UIAlertAction(title: option, style: .Default, handler: nil)
                
                alert.addAction(action)
            }
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
