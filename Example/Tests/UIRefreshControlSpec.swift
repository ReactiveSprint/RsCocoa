//
//  UIRefreshControlSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Quick
import Nimble
import ReactiveSprint

class UIRefreshControlSpec: QuickSpec {

    override func spec() {
        
        let refreshControl = UIRefreshControl()
        
        it("should start/stop animating") {
            refreshControl.loading = true
            
            expect(refreshControl.refreshing) == true
            
            refreshControl.loading = false
            
            expect(refreshControl.refreshing) == false
        }
        
    }

}
