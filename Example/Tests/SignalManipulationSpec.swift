//
//  SignalManipulationSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 2/28/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class SignalManipulationSpec: QuickSpec {
    
    override func spec() {
        
        var viewModel: ViewModel!
        
        beforeEach {
            viewModel = ViewModel(title: "TestViewModel")
        }
        
        ///
        /// Original `active` implementation and tests from
        /// [ReactiveViewModel.](https://github.com/ReactiveCocoa/ReactiveViewModel)
        ///
        describe("active property") {
            
            it("should default to false") {
                expect(viewModel.active.value) == false
            }
            
            it("should send on didBecomeActive when set to true") {
                var nextEvents = 0
                
                viewModel.didBecomeActive.startWithNext { viewModel2 in
                    expect(viewModel2) === viewModel
                    
                    expect(viewModel.active.value) == true
                    
                    nextEvents += 1
                }
                
                expect(nextEvents) == 0
                
                viewModel.active.value = true
                
                expect(nextEvents) == 1
                
                // Indistinct changes should not trigger the signal again.
                viewModel.active.value = true
                expect(nextEvents) == 1
                
                viewModel.active.value = false
                viewModel.active.value = true
                expect(nextEvents) == 2
            }
            
            it("should send on didBecomeInactive when set to false") {
                var nextEvents = 0
                
                viewModel.didBecomeInActive.startWithNext { viewModel2 in
                    expect(viewModel2) === viewModel
                    
                    expect(viewModel.active.value) == false
                    
                    nextEvents += 1
                }
                
                expect(nextEvents) == 1
                
                viewModel.active.value = true
                viewModel.active.value = false
                expect(nextEvents) == 2
                
                // Indistinct changes should not trigger the signal again.
                viewModel.active.value = false
                expect(nextEvents) == 2
            }
            
            context("SignalProducer forwarding") {
                var values: [Int]!
                var expectedValues: [Int]!
                var completed = false
                
                beforeEach {
                    values = [Int]()
                    viewModel.active.value = true
                }
                
                afterEach {
                    viewModel = nil
                    expect(completed).toEventually(beTrue())
                }
                
                it("should forward SignalProducer") {
                    let signal = SignalProducer<Int, NoError> { (observer, disposable) in
                        observer.sendNext(1)
                        observer.sendNext(2)
                    }
                    
                    signal.forwardWhileActive(viewModel)
                        .start(Observer(failed: nil,
                            completed: { completed = true },
                            interrupted: nil,
                            next: { values.append($0) }))
                    
                    expectedValues = [1, 2]
                    expect(values).toEventually(equal(expectedValues))
                    expect(completed) == false
                    
                    viewModel.active.value = false
                    expect(values).toEventually(equal(expectedValues))
                    expect(completed) == false
                    
                    viewModel.active.value = true
                    
                    expectedValues = [1, 2, 1, 2]
                    expect(values).toEventually(equal(expectedValues))
                    expect(completed) == false
                }
                
            }
            
            context("SignalProducer throttling") {
                var values: [Int]!
                var expectedValues: [Int]!
                var completed = false
                
                beforeEach {
                    values = [Int]()
                    viewModel.active.value = true
                }
                
                afterEach {
                    viewModel = nil
                    expect(completed).toEventually(beTrue())
                }
                
                it("should throttle SignalProducer") {
                    let (signal, observer) = SignalProducer<Int, NoError>.buffer(1)
                    
                    signal.throttleWhileInactive(viewModel, interval: 1, onScheduler: QueueScheduler.mainQueueScheduler)
                        .start(Observer(failed: nil,
                            completed: { completed = true },
                            interrupted: nil,
                            next: {
                                values.append($0) }))
                    
                    observer.sendNext(1)
                    
                    expectedValues = [1]
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    viewModel.active.value = false
                    
                    observer.sendNext(2)
                    observer.sendNext(3)
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    expectedValues = [1, 3]
                    expect(values).toEventually(equal(expectedValues), timeout: 2)
                    expect(completed) == false
                    
                    // After reactivating, we should still get this event.
                    observer.sendNext(4)
                    viewModel.active.value = true
                    
                    expectedValues = [1, 3, 4]
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    // And now new events should be instant.
                    observer.sendNext(5)
                    expectedValues = [1, 3, 4, 5]
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    observer.sendCompleted()
                    expect(values) == expectedValues
                    expect(completed) == true
                }
            }
            
            context("Signal manipulation") {
                var values: [Int]!
                var expectedValues: [Int]!
                var completed = false
                
                beforeEach {
                    values = [Int]()
                    viewModel.active.value = true
                }
                
                afterEach {
                    viewModel = nil
                    expect(completed).toEventually(beTrue())
                }
                
                it("should forward signal") {
                    let (signal, observer) = Signal<Int, NoError>.pipe()
                    
                    signal.forwardWhileActive(viewModel)
                        .observe(Observer(failed: nil,
                            completed: { completed = true },
                            interrupted: nil,
                            next: { values.append($0) }))
                    
                    observer.sendNext(1)
                    observer.sendNext(2)
                    
                    expectedValues = [1, 2]
                    expect(values).toEventually(equal(expectedValues))
                    expect(completed) == false
                    
                    viewModel.active.value = false
                    observer.sendNext(1)
                    expect(values).toEventually(equal(expectedValues))
                    expect(completed) == false
                    
                    viewModel.active.value = true
                    
                    observer.sendNext(1)
                    observer.sendNext(2)
                    expectedValues = [1, 2, 1, 2]
                    expect(values).toEventually(equal(expectedValues))
                    expect(completed) == false
                }
            }
            
            context("Signal throttling") {
                var values: [Int]!
                var expectedValues: [Int]!
                var completed = false
                
                beforeEach {
                    values = [Int]()
                    viewModel.active.value = true
                }
                
                afterEach {
                    viewModel = nil
                    expect(completed).toEventually(beTrue())
                }
                
                it("should throttle Signal") {
                    let (signal, observer) = Signal<Int, NoError>.pipe()
                    
                    signal.throttleWhileInactive(viewModel, interval: 1, onScheduler: QueueScheduler.mainQueueScheduler)
                        .observe(Observer(failed: nil,
                            completed: { completed = true },
                            interrupted: nil,
                            next: { values.append($0) }))
                    
                    observer.sendNext(1)
                    
                    expectedValues = [1]
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    viewModel.active.value = false
                    
                    observer.sendNext(2)
                    observer.sendNext(3)
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    expectedValues = [1, 3]
                    
                    expect(values).toEventually(equal(expectedValues), timeout: 2)
                    expect(completed) == false
                    
                    // After reactivating, we should still get this event.
                    observer.sendNext(4)
                    viewModel.active.value = true
                    
                    expectedValues = [1, 3, 4]
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    // And now new events should be instant.
                    observer.sendNext(5)
                    expectedValues = [1, 3, 4, 5]
                    expect(values) == expectedValues
                    expect(completed) == false
                    
                    observer.sendCompleted()
                    expect(values) == expectedValues
                    expect(completed) == true
                }
            }
            
        }
    }
}
