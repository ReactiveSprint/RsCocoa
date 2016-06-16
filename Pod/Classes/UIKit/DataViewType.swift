//
//  DataViewType.swift
//  Pods
//
//  Created by Ahmad Baraka on 6/16/16.
//
//

import Foundation

/// Represents any View which displays Data.
///
/// Extension implementation available for `UITableView`, and `UICollectionView`
@objc public protocol DataViewType {
    /// Requests the receiver to reload data.
    func reloadData()
}

extension UITableView: DataViewType {
    
}

extension UICollectionView: DataViewType {
    
}
