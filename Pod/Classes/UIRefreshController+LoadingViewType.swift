//
//  UIRefreshController+LoadingViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/17/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit

extension UIRefreshControl: LoadingViewType
{
    public var loading: Bool {
        get {
            return refreshing
        }
        
        set {
            if newValue
            {
                beginRefreshing()
            }
            else
            {
                endRefreshing()
            }
        }
    }
}
