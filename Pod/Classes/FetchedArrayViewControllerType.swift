//
//  FetchedArrayViewControllerType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation

/// Represents a ViewController that wraps FetchedArrayViewModel
public protocol FetchedArrayViewControllerType: ArrayViewControllerType {
    /// Returns `arrayViewModel`
    var fetchedArrayViewModel: CocoaFetchedArrayViewModelType { get }
    
    /// Binds `arrayViewModel.refreshing` to the receiver.
    func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType)
    
    /// Shows or hides a view that represents refreshing.
    func presentRefreshing(refreshing: Bool)
    
    /// Binds `arrayViewModel.fetchingNextPage` to the receiver.
    func bindFetchingNextPage(arrayViewModel: CocoaFetchedArrayViewModelType)
    
    /// Shows or hides a view that represents fetching next page.
    func presentFetchingNextPage(fetchingNextPage: Bool)
}

public extension FetchedArrayViewControllerType {
    public var fetchedArrayViewModel: CocoaFetchedArrayViewModelType {
        return arrayViewModel as! CocoaFetchedArrayViewModelType
    }
}

/// Binds `arrayViewModel.refreshing` to `presentRefreshing(_:)`
public func _bindRefreshing<ViewController: FetchedArrayViewControllerType where ViewController: NSObject>(arrayViewModel: CocoaFetchedArrayViewModelType, viewController: ViewController) {
    arrayViewModel.refreshing.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .skipRepeats()
        .forwardWhileActive(viewController.arrayViewModel)
        .startWithNext(viewController.presentRefreshing)
}

/// Binds `arrayViewModel.fetchingNextPage` to `presentFetchingNextPage(_:)`
public func _bindFetchingNextPage<ViewController: FetchedArrayViewControllerType where ViewController: NSObject>(arrayViewModel: CocoaFetchedArrayViewModelType, viewController: ViewController) {
    arrayViewModel.fetchingNextPage.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .skipRepeats()
        .forwardWhileActive(viewController.arrayViewModel)
        .startWithNext (viewController.presentFetchingNextPage)
}
