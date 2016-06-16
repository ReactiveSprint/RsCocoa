//
//  ViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveCocoa
import Result

/// General reuse Identifier.
///
/// This may be used for UITableViewCell or similar.
public let ViewModelIdentifier = "ViewModelIdentifier"

/// Represents a View/ViewController in MVVM pattern
/// which will wrap a `ViewModel`
public protocol ViewType: class {
    /// ViewModel used in the receiver.
    var viewModel: ViewModelType! { get set }
    
    /// Title of the receiver.
    var title: String? { get set }
    
    /// Shows or hides a view that represents loading.
    func presentLoading(loading: Bool)
    
    /// Presents `error` in an UIAlertController.
    func presentError(error: ViewModelErrorType)
}

public extension ViewType {
    /// Binds `viewModel` to the receiver.
    ///
    /// This should be called at `didSet` for viewModel property.
    /// Should be used to bind properties that are not related to views.
    /// For view-related bindings, use `viewDidLoad()`
    ///
    /// Invokes `bindActive(_:)`, `bindTitle(_:)` and `bindErrors(_:)`
    public func bindViewModel(viewModel: ViewModelType) -> Disposable {
        let disposable = CompositeDisposable()
        disposable += bindActive(viewModel)
        disposable += bindTitle(viewModel)
        disposable += bindErrors(viewModel)
        return disposable
    }
    
    /// Binds ViewModel's `active` property from the receiver.
    public func bindActive(viewModel: ViewModelType) -> Disposable! {
        return nil
    }
    
    /// Binds viewModel's title to the receiver title.
    public func bindTitle(viewModel: ViewModelType) -> Disposable {
        let titleProducer = viewModel.title.producer.forwardWhileActive(viewModel)
        return titleProducer.startWithNext { [unowned self] title in
            self.title = title
        }
    }
    
    /// Binds viewModel's loading to `presentLoading(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    public func bindLoading(viewModel: ViewModelType) -> Disposable {
        let loadingProducer = viewModel.loading.producer.forwardWhileActive(viewModel)
        return loadingProducer.startWithNext(presentLoading)
    }
    
    /// Binds viewModel's errors to `showErrors(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    public func bindErrors(viewModel: ViewModelType) -> Disposable? {
        return viewModel.errors.forwardWhileActive(viewModel).observeNext(presentError)
    }
}
