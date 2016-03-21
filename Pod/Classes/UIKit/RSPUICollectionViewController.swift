//
//  RSPUICollectionViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// UICollectionViewController that implements ArrayViewControllerType.
public class RSPUICollectionViewController: UICollectionViewController, ArrayViewControllerType
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
    
    public var arrayView: UICollectionView! {
        return collectionView
    }
    
    public var arrayViewModel: CocoaArrayViewModelType {
        return viewModel as! CocoaArrayViewModelType
    }
    
    public func bindViewModel(viewModel: ViewModelType)
    {
        _bindViewModel(viewModel, viewController: self)
        bindArrayViewModel(arrayViewModel)
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
        _presentLoading(loading, viewController: self)
    }
    
    public func bindErrors(viewModel: ViewModelType)
    {
        _bindErrors(viewModel, viewController: self)
    }
    
    public func presentError(error: ViewModelErrorType)
    {
        _presentError(error, viewController: self)
    }
    
    public func bindArrayViewModel(arrayViewModel: CocoaArrayViewModelType)
    {
        _bindArrayViewModel(arrayViewModel, viewController: self)
    }
}

/// UICollectionViewController subclass where `arrayViewModel` supports fetching and refreshing.
public class RSPUIFetchedCollectionViewController: RSPUICollectionViewController, FetchedArrayViewControllerType
{
    @IBOutlet public var refreshView: LoadingViewType?
    
    @IBOutlet public var fetchingNextPageView: LoadingViewType?
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let refreshView = self.refreshView as? UIControl
        {
            refreshView.addTarget(fetchedArrayViewModel.refreshCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.ValueChanged)
        }
        
        arrayView.rac_didScrollToHorizontalEnd().startWithNext { [unowned self] _ in
            self.fetchedArrayViewModel.fetchIfNeededCocoaAction.execute(nil)
        }
    }
    
    public override func bindArrayViewModel(arrayViewModel: CocoaArrayViewModelType)
    {
        super.bindArrayViewModel(arrayViewModel)
        bindRefreshing(fetchedArrayViewModel)
        bindFetchingNextPage(fetchedArrayViewModel)
    }
    
    public func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType)
    {
        _bindRefreshing(arrayViewModel, viewController: self)
    }
    
    public func bindFetchingNextPage(arrayViewModel: CocoaFetchedArrayViewModelType) {
        _bindFetchingNextPage(arrayViewModel, viewController: self)
    }
}

