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
    typealias ArrayView: NSObject
    
    var arrayViewModel: CocoaArrayViewModelType { get }
    
    var arrayView: ArrayView! { get }
    
    func reloadData()
    
    func bindArrayViewModel(arrayViewModel: CocoaArrayViewModelType)
}

/// Binds ArrayViewModel count property by invoking `reloadData()` for each distinct change.
public func _bindArrayViewModel<ViewController: ArrayViewControllerType where ViewController: NSObject>(arrayViewModel: CocoaArrayViewModelType, viewController: ViewController)
{
    arrayViewModel.count.producer
        .takeUntil(viewController.rac_willDeallocSignalProducer())
        .skipRepeats()
        .forwardWhileActive(viewController.arrayViewModel)
        .startWithNext { [unowned viewController] _ in viewController.reloadData() }
}
