//
//  FetchedArrayViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// Represents a ViewController that wraps FetchedArrayViewModel
public protocol FetchedArrayViewType: ArrayViewType {
    /// Shows or hides a view that represents refreshing.
    func presentRefreshing(refreshing: Bool)
    
    /// Shows or hides a view that represents fetching next page.
    func presentFetchingNextPage(fetchingNextPage: Bool)
}

public extension FetchedArrayViewType {
    var viewModel: CocoaFetchedArrayViewModelType! {
        return viewModel as! CocoaFetchedArrayViewModelType
    }
    
    /// Binds `arrayViewModel.refreshing` to `presentRefreshing(_:)`
    public func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType) -> Disposable {
        return arrayViewModel.refreshing.producer
            .skipRepeats()
            .forwardWhileActive(arrayViewModel)
            .startWithNext(presentRefreshing)
    }
    
    /// Binds `arrayViewModel.fetchingNextPage` to `presentFetchingNextPage(_:)`
    public func bindFetchingNextPage(arrayViewModel: CocoaFetchedArrayViewModelType) -> Disposable {
        return arrayViewModel.fetchingNextPage.producer
            .skipRepeats()
            .forwardWhileActive(arrayViewModel)
            .startWithNext (presentFetchingNextPage)
    }
}
