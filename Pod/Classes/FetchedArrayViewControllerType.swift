//
//  FetchedArrayViewControllerType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation

/// Represents a ViewController that wraps FetchedArrayViewModel and "ArrayView"
public protocol FetchedArrayViewControllerType: ArrayViewControllerType
{
    typealias RefreshView: LoadingViewType
    
    typealias FetchingNextPageView: LoadingViewType
    
    /// Returns `arrayViewModel`
    var fetchedArrayViewModel: CocoaFetchedArrayViewModelType { get }
    
    /// A view that presents "refreshing" state.
    ///
    /// This is typically a UIRefreshControl or similar
    /// but you can provide a custom class by implementing LoadingViewType
    var refreshView: RefreshView? { get }
    
    /// A view that presents requesting next page state.
    var fetchingNextPageView: FetchingNextPageView? { get }
    
    /// Binds `arrayViewModel.refreshing` to the receiver.
    func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType)
    
    /// Binds `arrayViewModel.fetchingNextPage` to the receiver.
    func bindFetchingNextPage(arrayViewModel: CocoaFetchedArrayViewModelType)
}

public extension FetchedArrayViewControllerType
{
    public var fetchedArrayViewModel: CocoaFetchedArrayViewModelType {
        return arrayViewModel as! CocoaFetchedArrayViewModelType
    }
}

/// Binds arrayViewModel refreshing by setting RefreshView.loading
public func _bindRefreshing<ViewController: FetchedArrayViewControllerType where ViewController: NSObject>(arrayViewModel: CocoaFetchedArrayViewModelType, viewController: ViewController)
{
    arrayViewModel.refreshing.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .skipRepeats()
        .forwardWhileActive(viewController.arrayViewModel)
        .startWithNext { [unowned viewController] refreshing in
            if let refreshView = viewController.refreshView
            {
                refreshView.loading = refreshing
            }
    }
}

/// Binds arrayViewModel fetchingNextPage by setting FetchingNextPageView.loading
public func _bindFetchingNextPage<ViewController: FetchedArrayViewControllerType where ViewController: NSObject>(arrayViewModel: CocoaFetchedArrayViewModelType, viewController: ViewController)
{
    arrayViewModel.fetchingNextPage.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .skipRepeats()
        .forwardWhileActive(viewController.arrayViewModel)
        .startWithNext { [unowned viewController] fetching in
            if let loadingView = viewController.fetchingNextPageView
            {
                loadingView.loading = fetching
            }
    }
}
