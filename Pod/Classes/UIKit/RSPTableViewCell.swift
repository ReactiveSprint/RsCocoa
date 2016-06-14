//
//  RSPTableViewCell.Swift
//  Pods
//
//  Created by Ahmad Baraka on 3/14/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/// UITableViewCell which uses a ViewModel.
///
/// Subclasses need to override `bindViewModel(_:).`
public class RSPTableViewCell: UITableViewCell, ViewType {
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
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        (self.rac_prepareForReuseSignalProducer, self.rac_prepareForReuseObserver) = SignalProducer.buffer(0)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    ///
    /// Default implementation binds `viewModel.title` to `textLabel.text`
    public func bindViewModel(viewModel: ViewModelType) {
        if let textLabel = self.textLabel {
            viewModel.title.producer
                .takeUntil(rac_prepareForReuseSignalProducer)
                .startWithNext { [unowned textLabel] text in
                    textLabel.text = text
            }
        }
        
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
}
