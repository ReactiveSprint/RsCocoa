//
//  UIActivityIndicatorViewSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSprint

class UIActivityIndicatorViewSpec: QuickSpec {
    
    override func spec() {
        
        let activityIndicator = UIActivityIndicatorView()
        
        it("should start/stop animating") {
            activityIndicator.loading = true
            
            expect(activityIndicator.isAnimating()) == true
            
            activityIndicator.loading = false
            
            expect(activityIndicator.isAnimating()) == false
        }
        
    }
    
}
