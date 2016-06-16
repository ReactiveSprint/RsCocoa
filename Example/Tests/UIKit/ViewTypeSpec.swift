//
//  ViewTypeSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 6/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class ViewTypeSpec: QuickSpec {
    class TestView: ViewType {
        var viewModel: ViewModelType!
        var title: String?
        
        func bindActive(viewModel: ViewModelType) -> Disposable! {
            return nil
        }
        
        func presentLoading(loading: Bool) {
            
        }
        
        func presentError(error: ViewModelErrorType) {
            
        }
    }
    
    override func spec() {
        var view: ViewType!
        var viewModel: ViewModel!
        
        beforeEach {
            viewModel = ViewModel()
            view = TestView()
            view.viewModel = viewModel
            view.bindViewModel(viewModel)
        }
        
        describe("binding") {
            it("should bind title") {
                expect(view.title).to(beNil())
                
                viewModel.title.value = "Test1"
                expect(view.title).to(beNil())
                
                viewModel.active.value = true
                
                viewModel.title.value = "Test2"
                expect(view.title) == "Test2"
                
                viewModel.title.value = "Test3"
                expect(view.title) == "Test3"
                
                viewModel.title.value = nil
                expect(view.title).to(beNil())

                viewModel.active.value = false
                viewModel.title.value = "Test4"
                expect(view.title).to(beNil())
            }
        }
    }
    
}
