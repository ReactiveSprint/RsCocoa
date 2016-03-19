//
//  RSPUITableViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit
import ReactiveCocoa

public extension ArrayViewControllerType where Self.ArrayView == UITableView
{
    public func reloadData()
    {
        arrayView.reloadData()
    }
}

public class RSPUITableViewController: RSPUIViewController, ArrayViewControllerType
{
    public var arrayViewModel: CocoaArrayViewModelType {
        return viewModel as! CocoaArrayViewModelType
    }
    
    @IBOutlet public var arrayView: UITableView!
    
    public override func bindViewModel(viewModel: ViewModel)
    {
        super.bindViewModel(viewModel)
        bindArrayViewModel(arrayViewModel)
    }
    
    public func bindArrayViewModel(arrayViewModel: CocoaArrayViewModelType)
    {
        _bindArrayViewModel(arrayViewModel, viewController: self)
    }
}

public class RSPUIFetchedTableViewController: RSPUITableViewController, FetchedArrayViewControllerType
{
    @IBOutlet public var refreshView: LoadingViewType?
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let refreshView = self.refreshView as? UIControl
        {
            refreshView.addTarget(fetchedArrayViewModel.refreshCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    public override func bindArrayViewModel(arrayViewModel: CocoaArrayViewModelType)
    {
        super.bindArrayViewModel(arrayViewModel)
        bindRefreshing(fetchedArrayViewModel)
    }
    
    public func bindRefreshing(arrayViewModel: CocoaFetchedArrayViewModelType)
    {
        _bindRefreshing(arrayViewModel, viewController: self)
    }
}
