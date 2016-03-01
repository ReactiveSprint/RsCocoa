//
//  ViewModelSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 2/22/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class ViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var viewModel: ViewModel!
        
        beforeEach {
            viewModel = ViewModel(title: "TestViewModel")
        }
        
        describe("Title") {
            
            it("should set title from init") {
                expect(viewModel.title.value) == "TestViewModel"
            }
        }
        
        describe("errors") {
            var error: NSError!
            var receivedError: ViewModelErrorType?
            var completed = false
            
            beforeEach {
                error = NSError(domain: "ViewModelError", code: 1, userInfo: nil)
                completed = false
                viewModel.errors.observeNext { receivedError = $0 }
                viewModel.errors.observeCompleted { completed = true }
            }
            
            afterEach {
                viewModel = nil
                expect(completed).toEventually(beTrue())
            }
            
            it("should forward error from error signal") {
                let (signal, observer) = Signal<NSError, NoError>.pipe()
                
                viewModel.bindErrors(signal)
                
                observer.sendNext(error)
                
                expect(receivedError! as NSError) == error
                expect(completed) == false
                
                observer.sendCompleted()
                expect(completed) == false
            }
            
            it("should forward error from action") {
                let action = Action<(), (), NSError> { (input) -> SignalProducer<(), NSError> in
                    return SignalProducer(error: error)
                }
                viewModel.bindAction(action)
                
                action.apply().start()
                expect(receivedError! as NSError) == error
                expect(completed) == false
            }
        }
        
        
        describe("loading") {
            var completed = false
            
            beforeEach {
                completed = false
                //default should be false
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                viewModel.loading.signal.observeCompleted {
                    completed = true
                }
            }
            
            afterEach {
                viewModel = nil
                expect(completed) == true
            }
            
            it("should forward loading from producer") {
                let (producer, observer) = SignalProducer<Bool, NoError>.buffer(0)
                let (otherProducer, otherObserver) = SignalProducer<Bool, NoError>.buffer(0)
                
                viewModel.bindLoading(producer)
                //binding an "empty" producer, should not get things to fail
                viewModel.bindLoading(otherProducer)
                
                //after binding, nothing should change
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                observer.sendNext(true)
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
                
                observer.sendNext(true)
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
                
                observer.sendNext(false)
                
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                otherObserver.sendNext(false)
                
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                otherObserver.sendNext(true)
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
            }
            
            it("should forward loading from signal") {
                let (signal, observer) = Signal<Bool, NoError>.pipe()
                let (otherSignal, otherObserver) = Signal<Bool, NoError>.pipe()
                
                viewModel.bindLoading(signal)
                //binding an "empty" signal, should not get things to fail
                viewModel.bindLoading(otherSignal)
                
                //after binding, nothing should change
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                observer.sendNext(true)
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
                
                observer.sendNext(true)
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
                
                observer.sendNext(false)
                
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                otherObserver.sendNext(false)
                
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                
                otherObserver.sendNext(true)
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
            }
            
            it("should forward loading from actions") {
                let (producer, observer) = SignalProducer<(), NoError>.buffer(0)
                let (otherProducer, otherObserver) = SignalProducer<(), NoError>.buffer(0)
                
                let action = Action(enabledIf: viewModel.enabled) { producer }
                let otherAction = Action(enabledIf: viewModel.enabled) { otherProducer }
                
                viewModel.bindAction(action)
                viewModel.bindAction(otherAction)
                
                //after binding, nothing should change
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                expect(action.enabled.value) == true
                expect(otherAction.enabled.value) == true
                
                action.apply().start()
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
                expect(action.enabled.value) == false
                expect(otherAction.enabled.value) == false
                
                observer.sendCompleted()
                
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                expect(action.enabled.value) == true
                expect(otherAction.enabled.value) == true
                
                otherAction.apply().start()
                
                expect(viewModel.loading.value) == true
                expect(viewModel.enabled.value) == false
                expect(action.enabled.value) == false
                expect(otherAction.enabled.value) == false
                
                otherObserver.sendCompleted()
                
                expect(viewModel.loading.value) == false
                expect(viewModel.enabled.value) == true
                expect(action.enabled.value) == true
                expect(otherAction.enabled.value) == true
            }
        }
    }
    
}
