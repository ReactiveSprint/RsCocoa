//
//  RSPUIViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// UIViewController which wraps `ViewModel`.
public class RSPUIViewController<ViewModel: ViewModelType>: UIViewController, ViewControllerType
{
    /// ViewModel which will be used as context for this "View."
    ///
    /// This property is expected to be set only once with a non-nil value.
    public var viewModel: ViewModel! {
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
    
    public func bindViewModel(viewModel: ViewModel)
    {
        _bindViewModel(viewModel, viewController: self)
    }
    
    public func bindActive(viewModel: ViewModel)
    {
        _bindActive(viewModel, viewController: self)
    }
    
    public func bindTitle(viewModel: ViewModel)
    {
        _bindTitle(viewModel, viewController: self)
    }
    
    public func bindLoading(viewModel: ViewModel)
    {
        _bindLoading(viewModel, viewController: self)
    }
    
    public func presentLoading(loading: Bool)
    {
        _presentLoading(loading, viewController: self)
    }
    
    public func bindErrors(viewModel: ViewModel)
    {
        _bindErrors(viewModel, viewController: self)
    }
    
    public func presentError(error: ViewModelErrorType)
    {
        _presentError(error, viewController: self)
    }
}

public func _bindActive<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(viewModel: ViewModelType, viewController: ViewController)
{
    let presented = RACSignal.merge([
        viewController.rac_signalForSelector(Selector("viewWillAppear:")).mapReplace(true)
            .doNext { NSLog("viewWillAppear: %@", $0.description) }
        , viewController.rac_signalForSelector(Selector("viewWillDisappear:")).mapReplace(false)
            .doNext { NSLog("viewWillDisappear: %@", $0.description) }
        ])
    
    let appActive = RACSignal.merge([
        NSNotificationCenter.defaultCenter()
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .mapReplace(true)
            .doNext { NSLog("UIApplicationDidBecomeActiveNotification: %@", $0.description) }
        , NSNotificationCenter.defaultCenter()
            .rac_addObserverForName(UIApplicationWillResignActiveNotification, object: nil)
            .mapReplace(false)
            .doNext { NSLog("UIApplicationWillResignActiveNotification: %@", $0.description) }
        ]).startWith(true)
        .doNext { NSLog("appActive: %@", $0.description) }
    
    let activeSignal = RACSignal.combineLatest([presented, appActive])
        .and()
        .toSignalProducer()
        .map { $0 as! Bool }
        .flatMapError { _ in SignalProducer<Bool, NoError>.empty }
    
    viewModel.active <~ activeSignal
}

public func _bindTitle<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(viewModel: ViewModel, viewController: ViewController)
{
    viewModel.title.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .startWithNext { [unowned viewController] in viewController.title = $0 }
}

public func _presentLoading<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(loading: Bool, viewController: ViewController)
{
    if let loadingView = viewController.loadingView
    {
        loadingView.loading = loading
    }
}

public func _presentError<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(error: ViewModelErrorType, viewController: ViewController)
{
    viewController.presentViewController(UIAlertController(error: error), animated: true, completion: nil)
}
