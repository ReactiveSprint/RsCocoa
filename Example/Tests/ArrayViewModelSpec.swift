//
//  ArrayViewModelSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/3/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class ArrayViewModelSpec: QuickSpec {
    
    override func spec() {
        
        describe("ArrayViewModel") {
            var arrayViewModel: ArrayViewModel<TestViewModel>!
            var viewModels: [TestViewModel]!
            let title = "TestArrayViewModel"
            
            beforeEach {
                arrayViewModel = nil
                
                viewModels = generateViewModels(3)
            }
            
            it("default values") {
                arrayViewModel = ArrayViewModel([])
                
                expect(arrayViewModel.title.value).to(beNil())
                expect(arrayViewModel.localizedEmptyMessage.value).to(beNil())
                expect(arrayViewModel.count.value) == 0
                expect(arrayViewModel.isEmpty.value) == true
            }
            
            it("should set values from init(_, title:)") {
                arrayViewModel = ArrayViewModel(viewModels, title: title)
                
                expect(arrayViewModel.title.value) == title
                expect(arrayViewModel.localizedEmptyMessage.value).to(beNil())
                expect(arrayViewModel.count.value) == viewModels.count
                expect(arrayViewModel.isEmpty.value) == false
            }
            
            it("should set values from init(_, title:, localizedEmptyMessage:)") {
                let message = "No Items Available"
                arrayViewModel = ArrayViewModel(viewModels,
                    title: title,
                    localizedEmptyMessage: message)
                
                expect(arrayViewModel.title.value) == title
                expect(arrayViewModel.localizedEmptyMessage.value) == message
                expect(arrayViewModel.count.value) == viewModels.count
                expect(arrayViewModel.isEmpty.value) == false
            }
            
            it("subscript should return item") {
                arrayViewModel = ArrayViewModel(viewModels)
                
                expect(arrayViewModel[0].title.value) == "1"
                expect(arrayViewModel[1].title.value) == "2"
                expect(arrayViewModel[2].title.value) == "3"
            }
            
            it("should return index of object") {
                arrayViewModel = ArrayViewModel(viewModels)
                
                let viewModel = viewModels[1]
                
                expect(arrayViewModel.indexOf { $0 == viewModel }) == 1
                
                expect(arrayViewModel.indexOf(viewModel)) == 1
            }
            
            it("should return nil index") {
                arrayViewModel = ArrayViewModel(viewModels)
                
                let viewModel = TestViewModel(title: "4")
                
                expect(arrayViewModel.indexOf(viewModel)).to(beNil())
            }
        }
    }
    
}
