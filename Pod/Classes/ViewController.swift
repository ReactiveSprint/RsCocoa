//
//  ViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// ViewController which wraps `ViewModel`.
public class ViewController<ViewModel: ViewModelType>: UIViewController, ViewType
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
    
    /// Used to bind viewModel's title.
    private lazy var titleProperty: DynamicProperty = DynamicProperty(object: self, keyPath: "title")
    
    /// A UIView that is used to present loading to user.
    ///
    /// Your UIView may optionally conform to `LoadingViewType` protocol.
    @IBOutlet public var loadingView: UIView?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Binds `viewModel` to the receiver.
    ///
    /// This is called at `didSet` for viewModel property.
    ///
    /// Default implementation calls `bindActive(_:)` , `bindTitle(_:)`, `bindLoading(_:)`
    /// and `bindErrors(_:)`
    public func bindViewModel(viewModel: ViewModel)
    {
        bindActive(viewModel)
        bindTitle(viewModel)
        bindLoading(viewModel)
        bindErrors(viewModel)
    }
    
    /// Binds viewModel's title to the receiver title.
    public func bindTitle(viewModel: ViewModel)
    {
        titleProperty <~ viewModel.title.producer.map { $0 as AnyObject? }
    }
    
    /// Binds viewModel's loading to `showLoading(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    public func bindLoading(viewModel: ViewModel)
    {
        let loadingProducer = viewModel.loading.producer.forwardWhileActive(viewModel)
        loadingProducer.startWithNext(self.presentLoading)
    }
    
    /// Shows or hides loading view.
    ///
    /// Default implementation shows or hides `loadingView` if set.
    ///
    /// If loadingView is LoadingViewType, then `LoadingViewType.loading` will be set.
    public func presentLoading(loading: Bool)
    {
        if let loadingView = self.loadingView
        {
            if loadingView is LoadingViewType
            {
                var loadingViewType = loadingView as! LoadingViewType
                
                loadingViewType.loading = loading
            }
            else
            {
                loadingView.hidden = !loading
            }
        }
    }
    
    /// Binds viewModel's errors to `showErrors(_:)`
    ///
    /// Default binding uses `forwardWhileActive(_:).`
    public func bindErrors(viewModel: ViewModel)
    {
        viewModel.errors.forwardWhileActive(viewModel).observeNext(self.presentError)
    }
    
    /// Presents `error` in an UIAlertController.
    public func presentError(error: ViewModelErrorType)
    {
        presentViewController(UIAlertController(error: error), animated: true, completion: nil)
    }
}

public extension UIViewController
{
    /// Binds ViewModel's `active` property from the receiver.
    ///
    /// When `viewDidAppear(_:)` is called or `UIApplicationDidBecomeActiveNotification` is sent
    /// ViewModel's active is set to `true.`
    ///
    /// When `viewWillDisappear(_:)` is called or `UIApplicationWillResignActiveNotification` is sent
    /// ViewModel's active is set to `false.`
    public func bindActive(viewModel: ViewModelType)
    {
        let presented = RACSignal.merge([
            rac_signalForSelector(Selector("viewWillAppear:")).mapReplace(true)
                .doNext { NSLog("viewWillAppear: %@", $0.description) }
            , rac_signalForSelector(Selector("viewWillDisappear:")).mapReplace(false)
            .doNext { NSLog("viewWillDisappear: %@", $0.description) }
            ])
        
        let appActive = RACSignal.merge([
            NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
                .mapReplace(true)
                .doNext { NSLog("UIApplicationDidBecomeActiveNotification: %@", $0.description) }
            , NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationWillResignActiveNotification, object: nil)
                .mapReplace(false)
                .doNext { NSLog("UIApplicationWillResignActiveNotification: %@", $0.description) }
            ]).startWith(true)
            .doNext { NSLog("appActive: %@", $0.description) }
        
        let activeSignal = RACSignal.combineLatest([presented, appActive])
            .and()
            .toSignalProducer()
            .map { $0 as! Bool }
            .flatMapError { _ in SignalProducer<Bool, NoError>.empty }
        
        viewModel.active <~ activeSignal
    }
}
