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

class FetchedArrayViewModelSpec: QuickSpec {
    
    override func spec() {
        //TODO: Test errors with refresh
        //TODO: Test errors with pagination
        typealias SignalProducerType = SignalProducer<(Int?, [TestViewModel]), NSError>
        typealias ObserverType = Observer<(Int?, [TestViewModel]), NSError>
        
        var scheduler: TestScheduler!
        
        beforeEach {
            scheduler = TestScheduler()
        }
        
        describe("refreshAction") {
            var viewModel: FetchedArrayViewModel<TestViewModel, Int, NSError>!
            
            beforeEach {
                viewModel = FetchedArrayViewModel { _ -> SignalProducerType in
                    return SignalProducer(value: (nil, generateViewModels(4)))
                        .startOn(scheduler)
                }
            }
            
            it("should request") {
                var completed = false
                
                expect(viewModel.loading.value) == false
                expect(viewModel.refreshing.value) == false
                expect(viewModel.fetchingNextPage.value) == false
                
                viewModel.refreshAction.apply().startWithCompleted { completed = true  }
                
                expect(viewModel.loading.value) == true
                expect(viewModel.refreshing.value) == true
                expect(viewModel.fetchingNextPage.value) == false
                
                scheduler.advance()
                
                expect(viewModel.viewModels.count) == 4
                expect(viewModel.count.value) == 4
                expect(completed) == true
                expect(viewModel.refreshing.value) == false
                expect(viewModel.fetchingNextPage.value) == false
                expect(viewModel.loading.value) == false
                
                completed = false
                
                viewModel.refreshAction.apply().startWithCompleted { completed = true  }
                
                expect(viewModel.refreshing.value) == true
                expect(viewModel.count.value) == 4
                
                scheduler.advance()
                
                expect(viewModel.refreshing.value) == false
                expect(viewModel.count.value) == 4
            }
            
            it("should clear pre refresh") {
                viewModel.shouldClearPreRefresh = true
                
                viewModel.refreshAction.apply().start()
                
                scheduler.advance()
                expect(viewModel.count.value) == 4
                
                viewModel.refreshAction.apply().start()
                
                expect(viewModel.refreshing.value) == true
                expect(viewModel.count.value) == 0
                
                scheduler.advance()
                
                expect(viewModel.refreshing.value) == false
                expect(viewModel.count.value) == 4
            }
        }
        
        describe("fetchAction") {
            var viewModel: FetchedArrayViewModel<TestViewModel, Int, NSError>!
            
            beforeEach {
                viewModel = FetchedArrayViewModel { previousPage -> SignalProducer<( Int?, [TestViewModel]), NSError> in
                    var nextPage = 0
                    
                    if let page = previousPage
                    {
                        nextPage = page + 1
                    }
                    
                    return SignalProducer(value: (nextPage, generateViewModels(4, startValue: nextPage * 4)))
                        .startOn(scheduler)
                }
            }
            
            it("should fetch with pagination") {
                viewModel.fetchAction.apply().start()
                
                expect(viewModel.refreshing.value) == true
                expect(viewModel.fetchingNextPage.value) == false
                
                scheduler.advance()
                
                expect(viewModel.viewModels.count) == 4
                expect(viewModel.count.value) == 4
                
                //Fetching next page
                viewModel.fetchAction.apply().start()
                
                expect(viewModel.refreshing.value) == false
                expect(viewModel.fetchingNextPage.value) == true
                
                scheduler.advance()
                
                expect(viewModel.viewModels.count) == 8
                expect(viewModel.count.value) == 8
                
                // Fetching next page again
                viewModel.fetchIfNeeded().start()
                
                expect(viewModel.refreshing.value) == false
                expect(viewModel.fetchingNextPage.value) == true
                
                scheduler.advance()
                
                expect(viewModel.viewModels.count) == 12
                expect(viewModel.count.value) == 12
                
                //Refresh should start from 0
                viewModel.refreshAction.apply().start()
                expect(viewModel.refreshing.value) == true
                expect(viewModel.fetchingNextPage.value) == false
                
                scheduler.advance()
                expect(viewModel.viewModels.count) == 4
                expect(viewModel.count.value) == 4
            }
            
            it("should keep same order") {
                viewModel.fetchAction.apply().start()
                scheduler.advance()
                expect(viewModel.count.value) == 4
                expect(viewModel[0].title.value) == "1"
                expect(viewModel[1].title.value) == "2"
                expect(viewModel[2].title.value) == "3"
                expect(viewModel[3].title.value) == "4"
                
                viewModel.fetchIfNeeded().start()
                scheduler.advance()
                expect(viewModel.count.value) == 8
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
                scheduler.advance()
                expect(viewModel.count.value) == 4
                
                
                viewModel.fetchAction.unsafeCocoaAction.execute(UIView())
                scheduler.advance()
                expect(viewModel.count.value) == 8
            }
        }
    }
}
