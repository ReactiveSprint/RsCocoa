//
//  ArrayViewControllerType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// Represents a ViewController that wraps ArrayViewModel and "ArrayView"
public protocol ArrayViewControllerType: ViewControllerType
{
    /// Returns a ViewModel used as "ArrayViewModel"
    var arrayViewModel: CocoaArrayViewModelType { get }
    
    /// Binds `arrayViewModel` to the reciever.
    func bindArrayViewModel(arrayViewModel: CocoaArrayViewModelType)
    
    /// Reloads `arrayView`
    func reloadData()
}

/// Binds ArrayViewModel count property by invoking `reloadData()` for each distinct change.
public func _bindArrayViewModel<ViewController: ArrayViewControllerType where ViewController: NSObject>(arrayViewModel: CocoaArrayViewModelType, viewController: ViewController)
{
    arrayViewModel.count.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .skipRepeats()
        .forwardWhileActive(viewController.arrayViewModel)
        .map { _ in () }
        .startWithNext(viewController.reloadData)
}
