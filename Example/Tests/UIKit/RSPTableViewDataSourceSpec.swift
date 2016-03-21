//
//  RSPTableViewDataSourceSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import XCTest
import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

let TestIdentifier = "TestIdentifier"

class TestTableViewCell: RSPTableViewCell
{
    
}

class RSPTableViewDataSourceSpec: QuickSpec {
    
    override func spec() {
        
        var arrayViewModel: ArrayViewModel<ViewModel>!
        var dataSource: RSPTableViewDataSource!
        let tableView = UITableView()
        
        describe("DataSource") {
            beforeEach {
                arrayViewModel = ArrayViewModel(generateViewModels(5))
                dataSource = RSPTableViewDataSource(arrayViewModel: arrayViewModel)
                tableView.dataSource = dataSource
                
                tableView.registerClass(RSPTableViewCell.self, forCellReuseIdentifier: ViewModelIdentifier)
            }
            
            it("should return numberOfRows") {
                expect(dataSource.tableView(tableView, numberOfRowsInSection: 0)) == 5
            }
            
            it("should return RSTableViewCell") {
                let cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                expect(cell).to(beAnInstanceOf(RSPTableViewCell.self))
                expect(cell.reuseIdentifier) == ViewModelIdentifier
            }
        }
        
        describe("Dynamic cells") {
            beforeEach {
                arrayViewModel = ArrayViewModel(generateViewModels(5))
                dataSource = RSPTableViewDataSource(arrayViewModel: arrayViewModel) { (viewModel, indexPath) in
                    if indexPath.row == 0
                    {
                        return ViewModelIdentifier
                    }
                    else
                    {
                        return TestIdentifier
                    }
                }
                tableView.dataSource = dataSource
                
                tableView.registerClass(RSPTableViewCell.self, forCellReuseIdentifier: ViewModelIdentifier)
                tableView.registerClass(TestTableViewCell.self, forCellReuseIdentifier: TestIdentifier)
            }
            
            it("should return RSTableViewCell") {
                var cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                expect(cell).to(beAnInstanceOf(RSPTableViewCell.self))
                expect(cell.reuseIdentifier) == ViewModelIdentifier
                
                cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                expect(cell).to(beAnInstanceOf(TestTableViewCell.self))
                expect(cell.reuseIdentifier) == TestIdentifier
            }
            
        }
    }
    
}
