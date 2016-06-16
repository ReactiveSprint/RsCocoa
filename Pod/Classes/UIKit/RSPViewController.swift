//
//  RSPswift
//  Pods
//
//  Created by Ahmad Baraka on 3/12/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// UIViewController which wraps `ViewModel`.
public class RSPViewController: UIViewController, ViewType {
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
    /// Otherwise, Override `presentLoading(_:)`
    @IBOutlet public var loadingView: UIView?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindLoading(viewModel)
    }
    
    /// Default implementation sets `loading` to `loadingView`
    /// if it conforms to `LoadingViewType` protocol.
    public func presentLoading(loading: Bool) {
        if let loadingView = self.loadingView as? LoadingViewType {
            loadingView.loading = loading
        }
    }
}

public extension ViewType where Self: UIViewController {
    /// Binds ViewModel's `active` property from `viewController`.
    ///
    /// When `viewDidAppear(_:)` is called or `UIApplicationDidBecomeActiveNotification` is sent
    /// ViewModel's active is set to `true.`
    ///
    /// When `viewWillDisappear(_:)` is called or `UIApplicationWillResignActiveNotification` is sent
    /// ViewModel's active is set to `false.`
    public func bindActive(viewModel: ViewModelType) -> Disposable! {
        let presented = RACSignal.merge([
            rac_signalForSelector(#selector(viewWillAppear(_:))).mapReplace(true)
            , rac_signalForSelector(#selector(viewWillDisappear(_:))).mapReplace(false)
            ])
        
        let appActive = RACSignal.merge([
            NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
                .mapReplace(true)
            , NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationWillResignActiveNotification, object: nil)
                .mapReplace(false)
            ]).startWith(true)
        
        let activeSignal = RACSignal.combineLatest([presented, appActive])
            .and()
            .toSignalProducer()
            .map { $0 as! Bool }
            .flatMapError { _ in SignalProducer<Bool, NoError>.empty }
        
        return viewModel.active <~ activeSignal
    }
    
    /// Presents an error
    ///
    /// Default implementation present an `UIAlertController(error:)`
    public func presentError(error: ViewModelErrorType) {
        presentViewController(UIAlertController(error: error), animated: true, completion: nil)
    }
}
