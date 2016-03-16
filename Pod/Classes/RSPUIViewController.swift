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

/// ViewController which wraps `ViewModel`.
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
    
    @IBOutlet public var loadingView: UIView?
    
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
