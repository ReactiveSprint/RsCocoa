//
//  RSPFetchedArrayViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 6/15/16.
//
//

import UIKit
import ReactiveCocoa

public class RSPFetchedArrayViewController: RSPArrayViewController, FetchedArrayViewType {
    /// A View which is used to display `refreshing` state of a ViewModel.
    ///
    /// If your view is a `UIControl` (typically a UIRefreshControl)
    /// its `ValueChanged` event will execute `CocoaFetchedArrayViewModelType.refreshCocoaAction`
    ///
    /// If your view conforms to `LoadingViewType`, it's updated as needed.
    /// Otherwise, override `presentRefreshing(_:)`
    @IBOutlet public var refreshingView: UIView?
    
    /// A View which is used to display `fetchingNextPageView` state of a ViewModel.
    ///
    /// If your view conforms to `LoadingViewType`, it's updated as needed.
    /// Otherwise, override `presentFetchingNextPage(_:)`
    @IBOutlet public var fetchingNextPageView: UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindRefreshing(viewModel)
        bindFetchingNextPage(viewModel)
        
        if let refreshingView = self.refreshingView as? UIControl {
            refreshingView.addTarget(viewModel.refreshCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    public func presentRefreshing(refreshing: Bool) {
        if let refreshingView = self.refreshingView as? LoadingViewType {
            refreshingView.loading = refreshing
        }
    }
    
    public func presentFetchingNextPage(fetchingNextPage: Bool) {
        if let fetchingNextPageView = self.fetchingNextPageView as? LoadingViewType {
            fetchingNextPageView.loading = fetchingNextPage
        }
    }
}
