# ReactiveSprint

[![CI Status](https://travis-ci.org/ReactiveSprint/CocoaReactiveSprint.svg?branch=master)](https://travis-ci.org/ReactiveSprint/CocoaReactiveSprint)  

ReactiveSprint (RSP) is a framework which provides API for developing apps with [Model-View-ViewModel](https://en.wikipedia.org/wiki/Model–view–viewmodel) (MVVM).

ReactiveSprint will be available for different platforms (Cocoa, Android, Windows.. etc) to unify the structure of projects for each platform and speedup the development process.

#### Compatibility

ReactiveSprint targets `Swift 2.2`, [ReactiveCocoa 4](https://github.com/ReactiveCocoa/ReactiveCocoa).

## Introduction

ReactiveSprint provides abstract implementation of common ViewModels and Views.

## Example: News Feed List

Let's say we need to display a list of posts for users. We want to have a ViewModel which fetches that list of posts, and a TableViewController that displays them.
With ReactiveSprint we only need to implment `UITableViewCell` that represents each Post cell, and a `ViewModel` for it.  
Here's what we typically need (In MVVM):
 1. [`Post` Model](#post-model)
 1. [`PostViewModel`](#postviewmodel) for each row.
 1. [`PostsViewModel`](#postsviewmodel) for fetching posts, handling refresh, maintaining an array of `PostViewModel` instaces.. etc.
 1. [`PostTableViewCell.`](#posttableviewcell)
 1. [`UITableViewDataSource.`](#poststableviewdatasource)
 1. Finally, [`PostsTableViewController.`](#poststableviewcontroller)

### Post Model

Implement [AnyModel](/Pod/Classes/Model.swift) protocol for our `Post` model.

```swift
struct Post: AnyModel {
    //Add Posts` properties
    var caption: MutableProperty<String>
}
```

### PostViewModel

We can subclass [ModelViewModel](/Pod/Classes/ModelViewModel.swift) to implement `PostViewModel` which will be used for each table view cell.

```swift
class PostViewModel: ModelViewModel<Post> {
    // Expose properties from `Post` which will be used in PostTableViewCell
    var caption: AnyProperty<String>
    
    override init(_ model: Post) {
        super.init(model)
        caption = AnyProperty(model.caption)
    }
}
```

### PostsViewModel

We also need to implement a ViewModel which fetches posts, maintains an Array of PostViewModel instances, handles refresh and possibly handle pagination too.  
We can either subclass [FetchedArrayViewModel](/Pod/Classes/FetchedArrayViewModel.swift) or initialize an instance:

```swift
let postsViewModel = FetchedArrayViewModel { page -> SignalProducer<([PostViewModel], Int?), NSError> in
    // requests posts for `page`
    return ApiClient.requestPosts(page)
}
```

This gives us a ViewModel which supports fetching, refreshing and pagination of posts.  
`ApiClient.requestPosts(:_)` takes an `Int` input as the page to be requested, and returns a SignalProducer which sends an array of `PostViewModel` and `Int` which will be used for requesting next page.

`FetchedArrayViewModel` has [ReactiveCocoa.Action](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/Action.swift) instances for refreshing, and fetching next pages.

### PostTableViewCell

We can subclass [RSPTableViewCell](/Pod/Classes/UIKit/RSPTableViewCell.swift) to implement `PostTableViewcell` and override `bindViewModel(_:)` to bind our ViewModel's properties to our cells.

```swift
class PostTableViewcell: RSPTableViewCell {
    
    @IBOutlet var captionLabel: UILabel!
    
    override bindViewModel(viewModel: ViewModelType) {
        precondition(viewModel is PostViewModel)
        super.bindViewModel(viewModel)
        
        let postViewModel = viewModel as! PostViewModel
        
        postViewModel.caption.producer
                .takeUntil(rac_prepareForReuseSignalProducer)
                .startWithNext { [unowned self] text in
                    self.captionLabel.text = text
            }
    }
}
```

### PostsTableViewDataSource

We can subclass or initialize [RSPTableViewDataSource](/Pod/Classes/UIKit/RSPTableViewDataSource.swift) to implement a `UITableViewDataSource` which uses `postsViewModel`.

```swift
let postsDataSource = RSPTableViewDataSource(arrayViewModel: arrayViewModel)
```

`RSPTableViewDataSource` uses `arrayViewModel.count` as count of rows.
And dequeues a cell with identifier [ViewModelIdentifier](/Pod/Classes/ViewType.swift) and sets an instance of `PostViewModel` for each cell.

### PostsTableViewController

We can subclass [RSPUIFetchedTableViewController](/Pod/Classes/UIKit/RSPUITableViewController.swift) to implement `PostsTableViewController` as a subclass of `UITableViewController.`
Or [RSPFetchedTableViewController](/Pod/Classes/UIKit/RSPTableViewController.swift) for a custom UIViewController with a `UITableView.` 

```swift
class PostsTableViewController: RSPUIFetchedTableViewController {
    
    /// self.viewModel should be set with instance of
    /// `PostsViewModel` some time before `viewDidLoad()`
    
    override viewDidLoad() {
        super.viewDidLoad()
        
        // Register `PostTableViewCell` for `ViewModelIdentifier`
        tableView.registerClass(PostTableViewcell.self, forCellReuseIdentifier: ViewModelIdentifier)
        
        tableView.dataSource = RSPTableViewDataSource(arrayViewModel: arrayViewModel)
    }
}
```

This is all we need to do to implement a table view of posts with refreshing, and pagination.
We only focus on implementing `PostTableViewCell` and its relative ViewModel `PostViewModel.`

## Installation

This project is currently under development. But a [CocoaPod](https://cocoapods.org) will be available. And [Carthage](https://github.com/Carthage/Carthage) will be supported as well.

## License

ReactiveSprint is available under the MIT license. See the LICENSE file for more info.
