//
//  UIScrollView+DidScroll.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/20/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

let UIScrollViewDelegateProxyKey = UnsafePointer<Void>(nilLiteral: ())

public extension UIScrollView
{
    private func rac_useDelegateProxy()
    {
        guard self.delegate !== self.rac_delegateProxy else
        {
            return
        }
        
        self.rac_delegateProxy.rac_proxiedDelegate = self.delegate
        self.delegate = self.rac_delegateProxy as? UIScrollViewDelegate
    }
    
    /// A delegate proxy which will be set as the receiver's delegate when any of the
    /// methods in this extension are used.
    public var rac_delegateProxy: RACDelegateProxy {
        var proxy = objc_getAssociatedObject(self, UIScrollViewDelegateProxyKey)
        
        if proxy == nil
        {
            proxy = RACDelegateProxy(withProtocol: UIScrollViewDelegate.self)
            objc_setAssociatedObject(self, UIScrollViewDelegateProxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return proxy as! RACDelegateProxy
    }
    
    /// Creates a SignalProducer which sends the receiver whenever `scrollViewDidScroll:` is called
    /// and completes when the receiver is deinitialized.
    public var rac_didScroll: SignalProducer<UIScrollView, NoError> {
        let producer = rac_delegateProxy.signalForSelector(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
            .takeUntil(rac_willDeallocSignal())
            .toSignalProducer()
            .map { ($0 as! RACTuple).first as! UIScrollView }
            .flatMapError { _ in SignalProducer<UIScrollView, NoError>.empty }
        
        rac_useDelegateProxy()
        
        return producer
    }
    
    /// Creates a SignalProducer which sends the receiver whenever the receiver scrolls to vertical end.
    public func rac_didScrollToVerticalEnd(margin: CGFloat = 0) -> SignalProducer<UIScrollView, NoError>
    {
        return rac_didScroll
            .filter { scrollView in
                let endScroll = scrollView.contentOffset.y + scrollView.frame.size.height + margin
                return endScroll >= scrollView.contentSize.height
        }
    }
    
    /// Creates a SignalProducer which sends the receiver whenever the receiver scrolls to horizontal end.
    public func rac_didScrollToHorizontalEnd(margin: CGFloat = 0) -> SignalProducer<UIScrollView, NoError>
    {
        return rac_didScroll
            .filter { scrollView in
                let endScroll = scrollView.contentOffset.x + scrollView.frame.size.width + margin
                return endScroll >= scrollView.contentSize.width
        }
    }
}
