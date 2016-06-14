//
//  TestModel.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/2/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveCocoa
import Result
import ReactiveSprint

public final class TestModel: ModelSaving, ModelFetching, ModelDeleting {
    public let objectId: ConstantProperty<Int>
    
    public init(objectId: Int) {
        self.objectId = ConstantProperty(objectId)
    }
    
    private func emptyProducer(input: Bool) -> SignalProducer<TestModel, NSError> {
        return SignalProducer { [unowned self] observer, disposable in
            if input {
                observer.sendNext(self)
                observer.sendCompleted()
            } else {
                let error = NSError(domain: "TestError", code: 0, userInfo: nil)
                observer.sendFailed(error)
            }
            }.delay(1, onScheduler: QueueScheduler.mainQueueScheduler)
    }
    
    public func save(input: Bool) -> SignalProducer<TestModel, NSError> {
        return emptyProducer(input)
    }
    
    public func fetch(input: Bool) -> SignalProducer<TestModel, NSError> {
        return emptyProducer(input)
    }
    
    public func delete(input: Bool) -> SignalProducer<TestModel, NSError> {
        return emptyProducer(input)
    }
}
