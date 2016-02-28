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
    }
    
}
