//
//  RSPCollectionViewCell.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

/// UICollectionViewCell which uses a ViewModel.
///
/// Subclasses need to override `bindViewModel(_:).`
public class RSPCollectionViewCell: UICollectionViewCell, ViewType {
    /// The Wrapped ViewModel.
    ///
    /// A setter is available to allow cell reuse.
    public var viewModel: ViewModelType! {
        didSet {
            if viewModel != nil
            {
                bindViewModel(viewModel)
            }
        }
    }
    
    /// A signal which will send a `Void` whenever -prepareForReuse is invoked upon
    /// the receiver.
    ///
    /// Use this instead of `rac_prepareForUseSignal`
    public let rac_prepareForReuseSignalProducer: SignalProducer<(), NoError>
    private let rac_prepareForReuseObserver: Observer<(), NoError>
    
    public var title: String? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    public override init(frame: CGRect) {
        (self.rac_prepareForReuseSignalProducer, self.rac_prepareForReuseObserver) = SignalProducer.buffer(0)
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        (self.rac_prepareForReuseSignalProducer, self.rac_prepareForReuseObserver) = SignalProducer.buffer(0)
        super.init(coder: aDecoder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        self.rac_prepareForReuseObserver.sendNext()
    }
    
    /// Used to bind ViewModel to UI elements.
    ///
    /// This is invoked at viewModel property's didSet.
    public func bindViewModel(viewModel: ViewModelType) {
        bindActive(viewModel)
    }
    
    public func bindActive(viewModel: ViewModelType) {
        let appActive = RACSignal.merge([
            NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
                .mapReplace(true)
            , NSNotificationCenter.defaultCenter()
                .rac_addObserverForName(UIApplicationWillResignActiveNotification, object: nil)
                .mapReplace(false)
            ]).startWith(true)
        
        let activeSignal = appActive
            .toSignalProducer()
            .map { $0 as! Bool }
            .flatMapError { _ in SignalProducer<Bool, NoError>.empty }
            .takeUntil(self.rac_prepareForReuseSignalProducer)
            .concat(SignalProducer(value: false))
        
        viewModel.active <~ activeSignal
    }
    
    public func presentLoading(loading: Bool) {
        
    }
    
    public func presentError(error: ViewModelErrorType) {
        
    }
}
