//
//  ViewControllerType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveCocoa
import Result

/// Represents a ViewController.
public protocol ViewControllerType: class, ViewType
{
    /// A UIView that is used to present loading to user.
    ///
    /// Your UIView may optionally conform to `LoadingViewType` protocol.
    var loadingView: UIView? { get }
    
    /// Binds ViewModel's `active` property from the receiver.
    ///
    /// When `viewDidAppear(_:)` is called or `UIApplicationDidBecomeActiveNotification` is sent
    /// ViewModel's active is set to `true.`
    ///
    /// When `viewWillDisappear(_:)` is called or `UIApplicationWillResignActiveNotification` is sent
    /// ViewModel's active is set to `false.`
    func bindActive(viewModel: ViewModel)
    
    /// Binds `viewModel` to the receiver.
    ///
    /// This is called at `didSet` for viewModel property.
    ///
    /// Default implementation calls `bindActive(_:)` , `bindTitle(_:)`, `bindLoading(_:)`
    /// and `bindErrors(_:)`
    func bindViewModel(viewModel: ViewModel)
    
    /// Binds viewModel's title to the receiver title.
    func bindTitle(viewModel: ViewModel)
    
    /// Binds viewModel's loading to `showLoading(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    func bindLoading(viewModel: ViewModel)
    
    /// Shows or hides loading view.
    ///
    /// Default implementation shows or hides `loadingView` if set.
    ///
    /// If loadingView is LoadingViewType, then `LoadingViewType.loading` will be set.
    func presentLoading(loading: Bool)
    
    /// Binds viewModel's errors to `showErrors(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    func bindErrors(viewModel: ViewModel)
    
    /// Presents `error` in an UIAlertController.
    func presentError(error: ViewModelErrorType)
}


// Composition is required since Swift *currently* doesn't support methods overriding
// if they were implemented/declared in extensions.

public func _bindViewModel<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(viewModel: ViewModel, viewController: ViewController)
{
    viewController.bindActive(viewModel)
    viewController.bindTitle(viewModel)
    viewController.bindLoading(viewModel)
    viewController.bindErrors(viewModel)
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

public func _bindLoading<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(viewModel: ViewModel, viewController: ViewController)
{
    let loadingProducer = viewModel.loading.producer.forwardWhileActive(viewModel)
    loadingProducer.startWithNext(viewController.presentLoading)
}

public func _presentLoading<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(loading: Bool, viewController: ViewController)
{
    if let loadingView = viewController.loadingView
    {
        if loadingView is LoadingViewType
        {
            var loadingViewType = loadingView as! LoadingViewType
            
            loadingViewType.loading = loading
        }
        else
        {
            loadingView.hidden = !loading
        }
    }
}

public func _bindErrors<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(viewModel: ViewModel, viewController: ViewController)
{
    viewModel.errors.forwardWhileActive(viewModel).observeNext(viewController.presentError)
}

public func _presentError<ViewModel: ViewModelType, ViewController: ViewControllerType where ViewController.ViewModel == ViewModel, ViewController: UIViewController>(error: ViewModelErrorType, viewController: ViewController)
{
    viewController.presentViewController(UIAlertController(error: error), animated: true, completion: nil)
}
