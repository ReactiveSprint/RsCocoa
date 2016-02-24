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
        
        describe("active property") {
            
            it("should default to false") {
                expect(viewModel.active.value) == false
            }
            
            it("should send on didBecomeActive when set to true") {
                var nextEvents = 0
                
                viewModel.didBecomeActive.startWithNext { viewModel2 in
                    expect(viewModel2) === viewModel
                    
                    expect(viewModel.active.value) == true
                    
                    nextEvents++
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
                    
                    nextEvents++
                }
                
                expect(nextEvents) == 1
                
                viewModel.active.value = true
                viewModel.active.value = false
                expect(nextEvents) == 2
                
                // Indistinct changes should not trigger the signal again.
                viewModel.active.value = false
                expect(nextEvents) == 2
            }
        }
    }
    
}
