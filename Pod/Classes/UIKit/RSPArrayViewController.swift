//
//  RSPArrayViewController.swift
//  Pods
//
//  Created by Ahmad Baraka on 6/15/16.
//
//

import UIKit
import ReactiveCocoa

/// General implementation of an `ArrayViewType`
///
/// `arrayView` must be set with any UIView.
///
/// Check `RSPUITableViewController` and `RSUICollectionViewController`
public class RSPArrayViewController: RSPViewController, ArrayViewType {
    public var localizedEmptyMessage: String? {
        get {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                return localizedEmptyMessageView.rs_text
            }
            else {
                return nil
            }
        }
        set {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                localizedEmptyMessageView.rs_text = newValue
            }
        }
    }
    public var localizedEmptyMessageHidden: Bool {
        get {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                return localizedEmptyMessageView.hidden
            }
            else {
                return true
            }
        }
        set {
            if let localizedEmptyMessageView = self.localizedEmptyMessageView as? TextViewType {
                localizedEmptyMessageView.hidden = newValue
            }
        }
    }
    
    /// View used to display your data.
    ///
    /// If your view conforms to `DataViewType` protocol,
    /// it's reloaded whenever `reloadData()` is called.
    /// Otherwise, override `reloadData()` to handle reloading data.
    @IBOutlet var arrayView: UIView!
    
    /// View used to display a message when `ArrayViewModel` is empty.
    ///
    /// If your view conforms to `TextViewType` protocol,
    /// it's shown or hidden whenever the viewModel is empty.
    ///
    /// Otherwise, override `localizedEmptyMessage` and `localizedEmptyMessageHidden`.
    @IBOutlet var localizedEmptyMessageView: UIView?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        precondition(arrayView != nil)
        bindCount(viewModel)
    }
    
    /// Requests to reload data displayed in `arrayView`
    ///
    /// Default implementation invokes `reloadData()` on `arrayView`
    /// if it conforms to protocol `DataViewType`
    public func reloadData() {
        if let arrayView = self.arrayView as? DataViewType {
            arrayView.reloadData()
        }
    }
}
