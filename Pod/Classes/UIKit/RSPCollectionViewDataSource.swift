//
//  RSPCollectionViewDataSource.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit

/// UICollectionViewDataSource implementation using an `CocoaArrayViewModelType` instance.
///
/// This implementation shows 1 section with `CocoaArrayViewModelType.count` rows.
/// `collectionView.dequeueReusableCellWithReuseIdentifier(_:forIndexPath:)` is used to dequeue cell
/// and a ViewModel is set to it.
public class RSPCollectionViewDataSource: NSObject, UICollectionViewDataSource
{
    /// ArrayViewModel source for the TableView.
    public let arrayViewModel: CocoaArrayViewModelType
    
    /// A closure which is invoked to return a reusue identifier to dequeue cells.
    public let cellIdentifierClosure: ((ViewModelType, NSIndexPath) -> String)?
    
    /// Initializes an instance with a dynamic cell identifier.
    ///
    /// - Parameter arrayViewModel: The view model source for the list.
    /// - Parameter cellIdentifierClosure: Will be invoked to return a reuse identifier used
    /// with `dequeueReusableCellWithReuseIdentifier(_:forIndexPath:)`
    ///
    /// If nil was sent, then `ViewModelIdentifier` is used instead.
    public init(arrayViewModel: CocoaArrayViewModelType, _ cellIdentifierClosure: (( ViewModelType, NSIndexPath) -> String)? = nil)
    {
        self.arrayViewModel = arrayViewModel
        self.cellIdentifierClosure = cellIdentifierClosure
    }
    
    /// Returns ArrayViewModel.count
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.arrayViewModel.count.value
    }
    
    /// Dequeues cell and sets ViewModel at `indexPath.row`.
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let viewModel = arrayViewModel[indexPath.row]
        
        let identifier: String
        
        if let cellIdentifierClosure = self.cellIdentifierClosure
        {
            identifier = cellIdentifierClosure(viewModel, indexPath)
        }
        else
        {
            identifier = ViewModelIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        
        if cell is RSPCollectionViewCell
        {
            (cell as! RSPCollectionViewCell).viewModel = viewModel
        }
        
        return cell
    }
}
