//
//  RSPViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// UIViewController which wraps `ViewModel`.
public class RSPViewController: UIViewController, ViewControllerType
{
    /// ViewModel which will be used as context for this "View."
    ///
    /// This property is expected to be set only once with a non-nil value.
    public var viewModel: ViewModelType! {
        didSet {
            precondition(oldValue == nil)
            bindViewModel(viewModel)
        }
    }
    
    @IBOutlet public var loadingView: LoadingViewType?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public func bindViewModel(viewModel: ViewModelType)
    {
        _bindViewModel(viewModel, viewController: self)
    }
    
    public func bindActive(viewModel: ViewModelType)
    {
        _bindActive(viewModel, viewController: self)
    }
    
    public func bindTitle(viewModel: ViewModelType)
    {
        _bindTitle(viewModel, viewController: self)
    }
    
    public func bindLoading(viewModel: ViewModelType)
    {
        _bindLoading(viewModel, viewController: self)
    }
    
    public func presentLoading(loading: Bool)
    {
        if let loadingView = self.loadingView
        {
            loadingView.loading = loading
        }
    }
    
    public func bindErrors(viewModel: ViewModelType)
    {
        _bindErrors(viewModel, viewController: self)
    }
    
    public func presentError(error: ViewModelErrorType)
    {
        _presentError(error, viewController: self)
    }
}

/// Binds ViewModel's `active` property from `viewController`.
///
/// When `viewDidAppear(_:)` is called or `UIApplicationDidBecomeActiveNotification` is sent
/// ViewModel's active is set to `true.`
///
/// When `viewWillDisappear(_:)` is called or `UIApplicationWillResignActiveNotification` is sent
/// ViewModel's active is set to `false.`
public func _bindActive<ViewController: ViewControllerType where ViewController: UIViewController>(viewModel: ViewModelType, viewController: ViewController)
{
    let presented = RACSignal.merge([
        viewController.rac_signalForSelector(Selector("viewWillAppear:")).mapReplace(true)
        , viewController.rac_signalForSelector(Selector("viewWillDisappear:")).mapReplace(false)
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

public func _bindTitle<ViewController: ViewControllerType where ViewController: UIViewController>(viewModel: ViewModelType, viewController: ViewController)
{
    viewModel.title.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .startWithNext { [unowned viewController] in viewController.title = $0 }
}

public func _presentError<ViewController: ViewControllerType where ViewController: UIViewController>(error: ViewModelErrorType, viewController: ViewController)
{
    viewController.presentViewController(UIAlertController(error: error), animated: true, completion: nil)
}
