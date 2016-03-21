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
    /// Binds viewModel's title to the receiver title.
    func bindTitle(viewModel: ViewModelType)
    
    /// Binds viewModel's loading to `presentLoading(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    func bindLoading(viewModel: ViewModelType)
    
    /// Shows or hides a view that represents loading.
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

/// Binds `viewModel` to the `viewController.`
///
/// This should be called at `didSet` for viewModel property.
/// Should be used to bind properties that are not related to views.
/// For view-related bindings, use `viewDidLoad()`
///
/// Invokes `bindActive(_:)`, `bindTitle(_:)` and `bindErrors(_:)`
public func _bindViewModel<ViewController: ViewControllerType>(viewModel: ViewModelType, viewController: ViewController)
{
    viewController.bindActive(viewModel)
    viewController.bindTitle(viewModel)
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
