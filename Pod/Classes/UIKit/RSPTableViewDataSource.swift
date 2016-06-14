//
//  RSPTableViewDataSource.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/15/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation

/// UITableViewDataSource implementation using an `CocoaArrayViewModelType` instance.
///
/// This implementation shows 1 section with `CocoaArrayViewModelType.count` rows.
/// `tableView.dequeueReusableCellWithIdentifier(_:forIndexPath:)` is used to dequeue cell
/// and a ViewModel is set to it.
public class RSPTableViewDataSource: NSObject, UITableViewDataSource {
    /// ArrayViewModel source for the TableView.
    public var arrayViewModel: CocoaArrayViewModelType!
    
    /// A closure which is invoked to return a reusue identifier to dequeue cells.
    public var cellIdentifierClosure: ((ViewModelType, NSIndexPath) -> String)?
    
    /// Initializes an instance.
    ///
    /// When this initializer is used, `arrayViewModel` must be set.
    public override init() {
        
    }
    
    /// Initializes an instance with a dynamic cell identifier.
    ///
    /// - Parameter arrayViewModel: The view model source for the list.
    /// - Parameter cellIdentifierClosure: Will be invoked to return a reuse identifier used
    /// with `dequeueReusableCellWithIdentifier(_:forIndexPath:)`
    ///
    /// If nil was sent, then `ViewModelIdentifier` is used instead.
    public init(arrayViewModel: CocoaArrayViewModelType, _ cellIdentifierClosure: (( ViewModelType, NSIndexPath) -> String)? = nil) {
        self.arrayViewModel = arrayViewModel
        self.cellIdentifierClosure = cellIdentifierClosure
    }
    
    /// Returns ArrayViewModel.count
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayViewModel.count.value
    }
    
    /// Dequeues cell and sets ViewModel at `indexPath.row`.
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel = arrayViewModel[indexPath.row]
        
        let identifier: String
        
        if let cellIdentifierClosure = self.cellIdentifierClosure {
            identifier = cellIdentifierClosure(viewModel, indexPath)
        } else {
            identifier = ViewModelIdentifier
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if cell is ViewType {
            (cell as! ViewType).viewModel = viewModel
        }
        
        return cell
    }
}
