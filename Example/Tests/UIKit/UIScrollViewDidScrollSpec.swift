//
//  UIScrollViewDidScrollSpec.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/20/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSprint

class UIScrollViewDidScrollSpec: QuickSpec {
    
    override func spec() {
        describe("didScroll") {
            
            context("vertical") {
                
                var scrollView: UIScrollView!
                let frame = CGRect(x: 0, y: 0, width: 320, height: 568)
                var offsets: [CGPoint]!
                var completed = false
                
                beforeEach {
                    offsets = [CGPoint]()
                    scrollView = UIScrollView(frame: frame)
                    scrollView.contentSize = CGSize(width: frame.width, height: frame.height * 4)
                }
                
                afterEach {
                    scrollView = nil
                    expect(completed) == true
                }
                
                it("should call rac_didScroll") {
                    scrollView.rac_didScroll.start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let scrollRect = CGRect(x: 0, y: frame.height * 2, width: frame.width, height: frame.height)
                    
                    scrollView.scrollRectToVisible(scrollRect, animated: true)
                    
                    expect(offsets.count) > 0
                }
                
                it("should not call rac_didScrollToVerticalEnd()") {
                    scrollView.rac_didScrollToVerticalEnd().start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let contentOffset = CGPoint(x: 0, y: (frame.height * 3) - 1 )
                    
                    scrollView.setContentOffset(contentOffset, animated: true)
                    
                    expect(offsets.count) == 0
                }
                
                it("should call rac_didScrollToVerticalEnd()") {
                    scrollView.rac_didScrollToVerticalEnd().start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let contentOffset = CGPoint(x: 0, y: frame.height * 3)
                    
                    scrollView.setContentOffset(contentOffset, animated: true)
                    
                    expect(offsets.count) > 0
                }
                
                it("should call rac_didScrollToVerticalEnd(20)") {
                    scrollView.rac_didScrollToVerticalEnd(20).start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let contentOffset = CGPoint(x: 0, y: (frame.height * 3) - 19)
                    
                    scrollView.setContentOffset(contentOffset, animated: true)
                    
                    expect(offsets.count) > 0
                }
            }
            
            context("horizontal") {
                
                var scrollView: UIScrollView!
                let frame = CGRect(x: 0, y: 0, width: 320, height: 568)
                var offsets: [CGPoint]!
                var completed = false
                
                beforeEach {
                    offsets = [CGPoint]()
                    scrollView = UIScrollView(frame: frame)
                    scrollView.contentSize = CGSize(width: frame.width * 4, height: frame.height)
                }
                
                afterEach {
                    scrollView = nil
                    expect(completed) == true
                }
                
                it("should not call rac_didScrollToHorizontalEnd()") {
                    scrollView.rac_didScrollToHorizontalEnd().start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let contentOffset = CGPoint(x: (frame.width * 3) - 1, y: 0 )
                    
                    scrollView.setContentOffset(contentOffset, animated: true)
                    
                    expect(offsets.count) == 0
                }
                
                it("should call rac_didScrollToHorizontalEnd()") {
                    scrollView.rac_didScrollToHorizontalEnd().start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let contentOffset = CGPoint(x: frame.width * 3, y: 0)
                    
                    scrollView.setContentOffset(contentOffset, animated: true)
                    
                    expect(offsets.count) > 0
                }
                
                it("should call rac_didScrollToHorizontalEnd(20)") {
                    scrollView.rac_didScrollToHorizontalEnd(20).start { event in
                        switch event
                        {
                        case let .Next(scrollValue):
                            offsets.append(scrollValue.contentOffset)
                        case .Completed:
                            completed = true
                        case .Failed: break
                        case .Interrupted: break
                        }
                    }
                    
                    let contentOffset = CGPoint(x: (frame.width * 3) - 19, y: 0)
                    
                    scrollView.setContentOffset(contentOffset, animated: true)
                    
                    expect(offsets.count) > 0
                }
            }
        }
    }
}
