//
//  FetchedArrayViewModelSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/2/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

/// Generates `count` of ViewModels, each ViewModel will have title of `index + startValue`
func generateViewModels(count: Int, startValue: Int = 0) -> [ViewModel]
{
    var viewModels = [ViewModel]()
    
    for index in 1...count
    {
        let viewModel = ViewModel(title: String(index + startValue))
        viewModels.append(viewModel)
    }
    
    return viewModels
}

class FetchedArrayViewModelSpec: QuickSpec {
    
    override func spec() {
        //TODO: Test errors with refresh
        //TODO: Test errors with pagination
        
        describe("fetchAction") {
            it("should fetch with no pagination") {
                let viewModel = FetchedArrayViewModel { _ -> SignalProducer<([ViewModel], Int?), NSError> in
                    SignalProducer(value: (generateViewModels(4), nil))
                        .delay(1, onScheduler: QueueScheduler.mainQueueScheduler)
                }
                
                var completed = false
                
                viewModel.fetchAction.apply().startWithCompleted { completed = true  }
                
                expect(viewModel.loading.value) == true
                expect(viewModel.refreshing.value) == true
                expect(viewModel.fetchingNextPage.value) == false
                expect(viewModel.viewModels.count).toEventually(equal(4), timeout: 2)
                expect(viewModel.count.value).toEventually(equal(4), timeout: 2)
                expect(completed) == true
                expect(viewModel.refreshing.value) == false
                expect(viewModel.fetchingNextPage.value) == false
                expect(viewModel.loading.value) == false
                
                completed = false
                
                /// Multiple calls should refresh
                viewModel.fetchAction.apply().startWithCompleted { completed = true  }
                
                expect(viewModel.refreshing.value) == true
                expect(viewModel.fetchingNextPage.value) == false
                
                //make sure fetch has finished
                expect(completed).toEventually(equal(true), timeout: 2)
                expect(viewModel.viewModels.count).toEventually(equal(4), timeout: 2)
                expect(completed) == true
                expect(viewModel.refreshing.value) == false
                expect(viewModel.fetchingNextPage.value) == false
            }
            
            context("pagination") {
                var viewModel: FetchedArrayViewModel<ViewModel, Int, NSError>!

                beforeEach {
                    viewModel = FetchedArrayViewModel { previousPage -> SignalProducer<([ViewModel], Int?), NSError> in
                        var nextPage = 0
                        
                        if let page = previousPage
                        {
                            nextPage = page + 1
                        }
                        
                        return SignalProducer(value: (generateViewModels(4, startValue: nextPage * 4), nextPage))
                            .delay(1, onScheduler: QueueScheduler.mainQueueScheduler)
                    }
                }
                
                it("should fetch with pagination") {
                    
                    viewModel.fetchAction.apply().start()
                    
                    expect(viewModel.refreshing.value) == true
                    expect(viewModel.fetchingNextPage.value) == false
                    expect(viewModel.viewModels.count).toEventually(equal(4), timeout: 2)
                    expect(viewModel.count.value).toEventually(equal(4), timeout: 2)
                    
                    viewModel.fetchAction.apply().start()
                    
                    expect(viewModel.refreshing.value) == false
                    expect(viewModel.fetchingNextPage.value) == true
                    expect(viewModel.viewModels.count).toEventually(equal(8), timeout: 2)
                    expect(viewModel.count.value).toEventually(equal(8), timeout: 2)
                    
                    viewModel.fetchIfNeeded().start()
                    
                    expect(viewModel.refreshing.value) == false
                    expect(viewModel.fetchingNextPage.value) == true
                    expect(viewModel.viewModels.count).toEventually(equal(12), timeout: 2)
                    expect(viewModel.count.value).toEventually(equal(12), timeout: 2)
                    
                    //Refresh should start from 0
                    viewModel.refreshAction.apply().start()
                    expect(viewModel.refreshing.value) == true
                    expect(viewModel.fetchingNextPage.value) == false
                    expect(viewModel.viewModels.count).toEventually(equal(4), timeout: 2)
                    expect(viewModel.count.value).toEventually(equal(4), timeout: 2)
                }
                
                it("should keep same order") {
                    viewModel.fetchAction.apply().start()
                    expect(viewModel.count.value).toEventually(equal(4), timeout: 2)
                    expect(viewModel[0].title.value) == "1"
                    expect(viewModel[1].title.value) == "2"
                    expect(viewModel[2].title.value) == "3"
                    expect(viewModel[3].title.value) == "4"
                    
                    viewModel.fetchIfNeeded().start()
                    expect(viewModel.count.value).toEventually(equal(8), timeout: 2)
                    expect(viewModel[0].title.value) == "1"
                    expect(viewModel[1].title.value) == "2"
                    expect(viewModel[2].title.value) == "3"
                    expect(viewModel[3].title.value) == "4"
                    expect(viewModel[4].title.value) == "5"
                    expect(viewModel[5].title.value) == "6"
                    expect(viewModel[6].title.value) == "7"
                    expect(viewModel[7].title.value) == "8"
                }
                
                it("should execute CocoaAction") {
                    viewModel.refreshAction.unsafeCocoaAction.execute(UIView())
                    
                    expect(viewModel.count.value).toEventually(equal(4), timeout: 2)
                    
                    viewModel.fetchAction.unsafeCocoaAction.execute(UIView())
                    
                    expect(viewModel.count.value).toEventually(equal(8), timeout: 2)
                }
            }
        }
    }
    
}
