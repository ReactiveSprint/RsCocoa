//
//  RSPUIViewControllerSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveCocoa
import Result
import ReactiveSprint

class RSPUIViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        describe("ViewController active") {
            
            var viewModel: ViewModel!
            var viewController: RSPUIViewController<ViewModel>!
            
            var loadingSignal: Signal<Bool, NoError>!
            var loadingObserver: Observer<Bool, NoError>!
            
            beforeEach {
                viewModel = ViewModel(title: "TestViewModel")
                viewController = RSPUIViewController(nibName: nil, bundle: nil)
                viewController.viewModel = viewModel
                
                let loading = Signal<Bool, NoError>.pipe()
                
                loadingSignal = loading.0
                loadingObserver = loading.1
                
                viewModel.bindLoading(loadingSignal)
            }
            
            it("should set active property") {
                // App is active
                // ViewController is not active
                expect(viewModel.active.value) == false
                
                // App is active
                // ViewController is active
                viewController.viewWillAppear(false)
                expect(viewModel.active.value) == true
                
                // App is active
                // ViewController is not active
                viewController.viewWillDisappear(false)
                expect(viewModel.active.value) == false
                
                // App is inactive
                // ViewController is active
                viewController.viewWillAppear(false)
                NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillResignActiveNotification, object: nil)
                expect(viewModel.active.value) == false
                
                
                // App is reactived
                // ViewController is active
                NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
                expect(viewModel.active.value) == true
            }
            
            it("should set ViewController title") {
                expect(viewController.title) == viewModel.title.value
                
                viewModel.title.value = "Test2"
                
                expect(viewController.title) == "Test2"
            }
            
            it("should set Loading View loading") {
                let loadingView = UIView()
                
                viewController.loadingView = loadingView
                
                expect(loadingView.hidden) == false
                
                viewController.viewWillAppear(true)

                expect(loadingView.hidden) == true
                
                loadingObserver.sendNext(true)
                
                expect(loadingView.hidden) == false
                
                loadingObserver.sendNext(false)
                
                expect(loadingView.hidden) == true
            }
            
            it("should set LoadingViewType loading") {
                let activityIndicator = UIActivityIndicatorView()
                
                viewController.loadingView = activityIndicator
                
                expect(activityIndicator.isAnimating()) == false
                
                loadingObserver.sendNext(true)
                
                expect(activityIndicator.isAnimating()) == false
                
                viewController.viewWillAppear(true)
                
                expect(activityIndicator.isAnimating()) == true
                
                loadingObserver.sendNext(false)
                
                expect(activityIndicator.isAnimating()) == false
            }
        }
    }
}
