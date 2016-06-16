//
//  RSPUICollectionViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// UICollectionViewController that implements ArrayViewType.
public class RSPUICollectionViewController: UICollectionViewController, ArrayViewType {
    /// ViewModel which will be used as context for this "View."
    ///
    /// This property is expected to be set only once with a non-nil value.
    public var viewModel: ViewModelType! {
        didSet {
            precondition(oldValue == nil)
            bindViewModel(viewModel)
        }
    }
    
    /// Gets or Sets a View used for displaying `loading` state of `viewModel`.
    ///
    /// If your view conforms to protocl `LoadingViewType`, it's loading state is handled.
    /// Otherwise, Override `presentLoading(_)`
    @IBOutlet public var loadingView: UIView?

    public var localizedEmptyMessage: String? {
        get {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                return localizedEmptyMessageView.rs_text
            }
            else {
                return nil
            }
        }
        set {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                localizedEmptyMessageView.rs_text = newValue
            }
        }
    }
    public var localizedEmptyMessageHidden: Bool {
        get {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                return localizedEmptyMessageView.hidden
            }
            else {
                return true
            }
        }
        set {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                localizedEmptyMessageView.hidden = newValue
            }
        }
    }
    
    /// View used to display a message when `ArrayViewModel` is empty.
    ///
    /// If your view conforms to `TextViewType` protocol,
    /// it's shown or hidden whenever the viewModel is empty.
    ///
    /// Otherwise, override `localizedEmptyMessage` and `localizedEmptyMessageHidden`.
    @IBOutlet var localizedEmptyMessageView: UIView?
    
    public var arrayView: UICollectionView! {
        return collectionView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindLoading(viewModel)
        bindCount(viewModel)
    }
    
    /// Default implementation sets `loading` to `loadingView`
    /// if it conforms to `LoadingViewType` protocol.
    public func presentLoading(loading: Bool) {
        if let loadingView = self.loadingView as? LoadingViewType {
            loadingView.loading = loading
        }
    }
    
    public func reloadData() {
        arrayView.reloadData()
    }
}

/// UICollectionViewController subclass where `arrayViewModel` supports fetching and refreshing.
public class RSPUIFetchedCollectionViewController: RSPUICollectionViewController, FetchedArrayViewType {
    /// A View which is used to display `refreshing` state of a ViewModel.
    ///
    /// If your view is a `UIControl` (typically a UIRefreshControl)
    /// its `ValueChanged` event will execute `CocoaFetchedArrayViewModelType.refreshCocoaAction`
    ///
    /// If your view conforms to `LoadingViewType`, it's updated as needed.
    /// Otherwise, override `presentRefreshing(_:)`
    @IBOutlet public var refreshView: UIView?
    
    /// A View which is used to display `fetchingNextPageView` state of a ViewModel.
    ///
    /// If your view conforms to `LoadingViewType`, it's updated as needed.
    /// Otherwise, override `presentFetchingNextPage(_:)`
    @IBOutlet public var fetchingNextPageView: UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bindRefreshing(viewModel)
        bindFetchingNextPage(viewModel)
        
        if let refreshView = self.refreshView as? UIControl {
            refreshView.addTarget(viewModel.refreshCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    public func presentRefreshing(refreshing: Bool) {
        if let refreshView = self.refreshView as? LoadingViewType {
            refreshView.loading = refreshing
        }
    }
    
    public func presentFetchingNextPage(fetchingNextPage: Bool) {
        if let fetchingNextPageView = self.fetchingNextPageView as? LoadingViewType {
            fetchingNextPageView.loading = fetchingNextPage
        }
    }
    
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        viewModel.fetchIfNeededCocoaAction.execute(nil)
    }
}
