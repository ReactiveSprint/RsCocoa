//
//  RSPTableViewCellSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class RSPTableViewCellSpec: QuickSpec {
    
    override func spec() {
        var viewModel: ViewModel!
        var cell: RSPTableViewCell!
        
        beforeEach {
            viewModel = ViewModel(title: "TestViewModel")
            
            cell = RSPTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: ViewModelIdentifier)
        }
        
        it("should set active property") {
            // App is active
            // Cell is not active
            expect(viewModel.active.value) == false
            
            // App is active
            // Cell is active
            cell.viewModel = viewModel
            expect(viewModel.active.value) == true
            
            // App is active
            // Cell is not active
            cell.prepareForReuse()
            expect(viewModel.active.value) == false
            expect(cell.viewModel).to(beNil())
            
            // App is inactive
            // Cell is active
            cell.viewModel = viewModel
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillResignActiveNotification, object: nil)
            expect(viewModel.active.value) == false
            
            // App is reactived
            // ViewController is active
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
            expect(viewModel.active.value) == true
        }
        
        it("should bind cell title") {
            cell.viewModel = viewModel
            
            expect(cell.textLabel!.text) == viewModel.title.value
            
            viewModel.title.value = "Test2"
            
            expect(cell.textLabel!.text) == "Test2"
        }
    }
    
}
