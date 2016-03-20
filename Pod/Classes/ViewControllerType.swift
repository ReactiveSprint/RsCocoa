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
    typealias LoadingView: LoadingViewType
    
    /// Binds ViewModel's `active` property from the receiver.
    ///
    /// When `viewDidAppear(_:)` is called or `UIApplicationDidBecomeActiveNotification` is sent
    /// ViewModel's active is set to `true.`
    ///
    /// When `viewWillDisappear(_:)` is called or `UIApplicationWillResignActiveNotification` is sent
    /// ViewModel's active is set to `false.`
    func bindActive(viewModel: ViewModelType)
    
    /// Binds `viewModel` to the receiver.
    ///
    /// This is called at `didSet` for viewModel property.
    ///
    /// Default implementation calls `bindActive(_:)` , `bindTitle(_:)`, `bindLoading(_:)`
    /// and `bindErrors(_:)`
    func bindViewModel(viewModel: ViewModelType)
    
    /// A LoadingViewType that is used to present loading to user.
    var loadingView: LoadingView? { get }
    
    /// Binds viewModel's title to the receiver title.
    func bindTitle(viewModel: ViewModelType)
    
    /// Binds viewModel's loading to `showLoading(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    func bindLoading(viewModel: ViewModelType)
    
    /// Shows or hides loading view.
    ///
    /// Default implementation shows or hides `loadingView` if set.
    ///
    /// If loadingView is LoadingViewType, then `LoadingViewType.loading` will be set.
    func presentLoading(loading: Bool)
    
    /// Binds viewModel's errors to `showErrors(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    func bindErrors(viewModel: ViewModelType)
    
    /// Presents `error` in an UIAlertController.
    func presentError(error: ViewModelErrorType)
}

// Composition is required since Swift *currently* doesn't support methods overriding
// if they were implemented/declared in extensions.

public func _bindViewModel<ViewController: ViewControllerType>(viewModel: ViewModelType, viewController: ViewController)
{
    viewController.bindActive(viewModel)
    viewController.bindTitle(viewModel)
    viewController.bindLoading(viewModel)
    viewController.bindErrors(viewModel)
}

public func _bindLoading<ViewController: ViewControllerType>(viewModel: ViewModelType, viewController: ViewController)
{
    let loadingProducer = viewModel.loading.producer.forwardWhileActive(viewModel)
    loadingProducer.startWithNext(viewController.presentLoading)
}

public func _bindErrors<ViewController: ViewControllerType>(viewModel: ViewModelType, viewController: ViewController)
{
    viewModel.errors.forwardWhileActive(viewModel).observeNext(viewController.presentError)
}
