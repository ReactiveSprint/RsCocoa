//
//  ArrayViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// Represents a View that wraps `ArrayViewModel` and `ArrayView`
public protocol ArrayViewType: ViewType {
    var localizedEmptyMessage: String? { get set }
    
    var localizedEmptyMessageHidden: Bool { get set }
    
    /// Reloads `arrayView`
    func reloadData()
}

public extension ArrayViewType {
    var viewModel: CocoaArrayViewModelType! {
        return viewModel as! CocoaArrayViewModelType
    }
    
    /// Binds ArrayViewModel `count` property by invoking `reloadData()` for each distinct change.
    public func bindCount(viewModel: CocoaArrayViewModelType) -> Disposable {
        return viewModel.count.producer
            .skipRepeats()
            .forwardWhileActive(viewModel)
            .map { _ in () }
            .startWithNext(reloadData)
    }
    
    /// Binds ArrayViewModel `localizedEmptyMessage` property
    /// by setting `ArrayViewType.localizedEmptyMessage`
    public func bindLocalizedEmptyMessage(viewModel: CocoaArrayViewModelType) -> Disposable  {
        return viewModel.localizedEmptyMessage.producer
            .forwardWhileActive(viewModel)
            .startWithNext { [unowned self] message in
                self.localizedEmptyMessage = message
        }
    }
    
    /// Binds ArrayViewModel `isEmpty` property by i
    /// setting `localizedEmptyMessageHidden` with each distinct value.
    public func bindLocalizedEmptyMessageHidden(viewModel: CocoaArrayViewModelType) -> Disposable  {
        return viewModel.isEmpty.producer
            .skipRepeats()
            .forwardWhileActive(viewModel)
            .startWithNext { [unowned self] empty in
                self.localizedEmptyMessageHidden = !empty
        }
    }
}
