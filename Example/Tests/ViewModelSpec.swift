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
        
    }
    
}
