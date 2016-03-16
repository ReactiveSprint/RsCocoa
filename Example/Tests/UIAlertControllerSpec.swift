//
//  UIAlertControllerSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/16/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSprint

class UIAlertControllerSpec: QuickSpec {
    
    override func spec() {
        
        it("should init UIAlertController from error") {
            
            let title = "Error Title"
            let message = "Error message"
            let cancel = "Cancel"
            
            let userInfo: [NSObject: AnyObject] = [NSLocalizedDescriptionKey : title
                , NSLocalizedRecoverySuggestionErrorKey: message
                , NSLocalizedRecoveryOptionsErrorKey: [cancel]]
            let error = NSError(domain: "TestDomain", code: 0, userInfo: userInfo)
            
            let alert = UIAlertController(error: error)
            
            expect(alert.title) == title
            
            expect(alert.message) == message
            
            expect(alert.actions.count) == 1
            
            expect(alert.actions[0].title) == cancel
        }
    }
    
}
