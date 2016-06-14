//
//  NSObject+RAC4Deallocating.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public extension NSObject {
    /// SignalProducer equivalent to `rac_willDeallocSignal()`
    public func rac_willDeallocSignalProducer() -> SignalProducer<(), NoError> {
        return rac_willDeallocSignal()
            .toSignalProducer()
            .map { _ in () }
            .flatMapError { _ in SignalProducer.empty }
    }
}
