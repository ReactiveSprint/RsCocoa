//
//  ModelViewModelSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/1/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class ModelViewModelSpec: QuickSpec {
    
    override func spec() {
        
        describe("Model Actions") {
            
            var model: TestModel!
            var viewModel: ModelViewModel<TestModel>!
            var saveAction: Action<Bool, TestModel, NSError>!
            var fetchAction: Action<Bool, TestModel, NSError>!
            var deleteAction: Action<Bool, TestModel, NSError>!
            
            beforeEach {
                model = TestModel(objectId: 1)
                viewModel = ModelViewModel(model)
                
                saveAction = viewModel.createSaveAction()
                fetchAction = viewModel.createFetchAction()
                deleteAction = viewModel.createDeleteAction()
            }
            
            it("should not allow concurrent execution") {
                expect(viewModel.model) === model
                
                //sending true for success
                saveAction.apply(true).start()
                expect(viewModel.loading.value) == true
                expect(saveAction.enabled.value) == false
                expect(fetchAction.enabled.value) == false
                expect(deleteAction.enabled.value) == false
                
                expect(viewModel.loading.value).toEventually(equal(false), timeout: 2)
                expect(saveAction.enabled.value).toEventually(equal(true), timeout: 1)
                expect(fetchAction.enabled.value).toEventually(equal(true), timeout: 1)
                expect(deleteAction.enabled.value).toEventually(equal(true), timeout: 1)
                
                fetchAction.apply(true).start()
                expect(viewModel.loading.value) == true
                expect(saveAction.enabled.value) == false
                expect(fetchAction.enabled.value) == false
                expect(deleteAction.enabled.value) == false
                
                expect(viewModel.loading.value).toEventually(equal(false), timeout: 2)
                expect(saveAction.enabled.value).toEventually(equal(true), timeout: 1)
                expect(fetchAction.enabled.value).toEventually(equal(true), timeout: 1)
                expect(deleteAction.enabled.value).toEventually(equal(true), timeout: 1)
                
                deleteAction.apply(true).start()
                expect(viewModel.loading.value) == true
                expect(saveAction.enabled.value) == false
                expect(fetchAction.enabled.value) == false
                expect(deleteAction.enabled.value) == false
                
                expect(viewModel.loading.value).toEventually(equal(false), timeout: 2)
                expect(saveAction.enabled.value).toEventually(equal(true), timeout: 1)
                expect(fetchAction.enabled.value).toEventually(equal(true), timeout: 1)
                expect(deleteAction.enabled.value).toEventually(equal(true), timeout: 1)
            }
            
            it("should forward error from actions") {
                
                var receivedError: ViewModelErrorType?
                
                viewModel.errors.observeNext { receivedError = $0 }
                
                saveAction.apply(false).start()
                expect(receivedError).toEventuallyNot(beNil())
                
                receivedError = nil
                
                fetchAction.apply(false).start()
                expect(receivedError).toEventuallyNot(beNil())
                
                receivedError = nil
                
                deleteAction.apply(false).start()
                expect(receivedError).toEventuallyNot(beNil())
            }
            
        }
    }
}
