//
//  RSPTableViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// An implementation of `ArrayViewControllerType` as UITableViewController.
///
/// Unlike RSPUITableViewController, this implementation doesn't require
/// your view to be UITableView.
/// And it doesn't create/modify your TableView.
public class RSPTableViewController: RSPViewController, ArrayViewControllerType {
    public var arrayViewModel: CocoaArrayViewModelType {
        return viewModel as! CocoaArrayViewModelType
    }
    
    @IBOutlet public var arrayView: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindLoading(viewModel)
        bindCount(arrayViewModel)
    }
    
    public func bindCount(arrayViewModel: CocoaArrayViewModelType) {
        _bindCount(arrayViewModel, viewController: self)
    }
    
    public func reloadData() {
        arrayView.reloadData()
    }
}

/// An implementation RSPTableViewController where `arrayViewModel` supports fetching and refreshing.
public class RSPFetchedTableViewController: RSPTableViewController, FetchedArrayViewControllerType {
    @IBOutlet public var refreshView: LoadingViewType?
    
    @IBOutlet public var fetchingNextPageView: LoadingViewType?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bindRefreshing(fetchedArrayViewModel)
        bindFetchingNextPage(fetchedArrayViewModel)
        
        if let refreshView = self.refreshView as? UIControl {
            refreshView.addTarget(fetchedArrayViewModel.refreshCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.ValueChanged)
        }
        
        arrayView.rac_didScrollToHorizontalEnd().startWithNext { [unowned self] _ in
            self.fetchedArrayViewModel.fetchIfNeededCocoaAction.execute(nil)
        }
    }
    
    public func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType) {
        _bindRefreshing(arrayViewModel, viewController: self)
    }
    
    public func presentRefreshing(refreshing: Bool) {
        if let refreshView = self.refreshView {
            refreshView.loading = refreshing
        }
    }
    
    public func bindFetchingNextPage(arrayViewModel: CocoaFetchedArrayViewModelType) {
        _bindFetchingNextPage(arrayViewModel, viewController: self)
    }
    
    public func presentFetchingNextPage(fetchingNextPage: Bool) {
        if let fetchingNextPageView = self.fetchingNextPageView {
            fetchingNextPageView.loading = fetchingNextPage
        }
    }
}
