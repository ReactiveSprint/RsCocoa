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
    
    var fetchedArrayViewModel: CocoaFetchedArrayViewModelType { get }
    
    var refreshView: RefreshView? { get }
    
    func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType)
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
