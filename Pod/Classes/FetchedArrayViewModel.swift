 //
//  FetchedArrayViewModel.Swift
//  Pods
//
//  Created by Ahmad Baraka on 3/2/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveCocoa
import Result

/// ArrayViewModel which its array is lazily fetched, or even paginated.
public protocol FetchedArrayViewModelType: class, ArrayViewModelType
{
    typealias FetchInput
    typealias PaginationType
    typealias FetchError: ViewModelErrorType
    
    /// Whether the ViewModel is refreshing.
    var refreshing: AnyProperty<Bool> { get }
    
    /// Whether the ViewModel is fetching next page and is not refreshing.
    var fetchingNextPage: AnyProperty<Bool> { get }
    
    /// Whether the ViewModel has next page.
    var hasNextPage: AnyProperty<Bool> { get }
    
    /// Next Page
    var nextPage: PaginationType? { get }
    
    /// Action which refreshes ViewModels.
    var refreshAction: Action<FetchInput, [Element], FetchError> { get }
    
    /// Action which fetches ViewModels.
    ///
    /// If `nextPage` is nil, then this action will refresh, else this action should fetch next page.
    var fetchAction: Action<FetchInput, [Element], FetchError> { get }
    
    /// Applies fetchAction only if next page is available.
    func fetchIfNeeded(input: FetchInput)
}

public extension FetchedArrayViewModelType
{
    private var willFetchNextPage: Bool {
        return nextPage != nil
    }
    
    public func fetchIfNeeded(input: FetchInput)
    {
        if willFetchNextPage && hasNextPage.value
        {
            fetchAction.apply(input).start()
        }
    }
}

/// An implementation of FetchedArrayViewModelType that fetches ViewModels by calling `fetchClosure.`
public class FetchedArrayViewModel<Element: ViewModel, PaginationType, FetchError: ViewModelErrorType>: ViewModel, FetchedArrayViewModelType
{
    private let _viewModels: MutableProperty<[Element]> = MutableProperty([])
    public var viewModels: [Element] {
        return _viewModels.value
    }
    
    private lazy var _count: AnyProperty<Int> = AnyProperty(initialValue: 0, producer: self._viewModels.producer.map { $0.count })
    private(set) public lazy var count: AnyProperty<Int> = AnyProperty(self._count)
    
    public let localizedEmptyMessage = MutableProperty<String?>(nil)
    
    private let _refreshing = MutableProperty(false)
    private(set) public lazy var refreshing: AnyProperty<Bool> = AnyProperty(self._refreshing)
    
    private let _fetchingNextPage = MutableProperty(false)
    private(set) public lazy var fetchingNextPage: AnyProperty<Bool> = AnyProperty(self._fetchingNextPage)
    
    private let _hasNextPage = MutableProperty(true)
    private(set) public lazy var hasNextPage: AnyProperty<Bool> = AnyProperty(self._hasNextPage)
    
    private(set) public var nextPage: PaginationType? = nil
    
    public let fetchClosure: PaginationType? -> SignalProducer<([Element], PaginationType?), FetchError>
    private(set) public lazy var refreshAction: Action<(), [Element], FetchError> = self.initRefreshAction()
    private(set) public lazy var fetchAction: Action<(), [Element], FetchError> = self.initFetchAction()
    
    /// Initializes an instance with `fetchClosure`
    ///
    /// - Parameter fetchClosure: A closure which is called each time `refreshAction` or `fetchAction`
    /// are called passing latest PaginationType
    /// and returns a `SignalProducer` which sends an array of `Element` and PaginationType.
    /// If the returned SignalProducer sends nil PaginationType, then no pagination will be handled.
    public init(_ fetchClosure: PaginationType? -> SignalProducer<([Element], PaginationType?), FetchError>)
    {
        self.fetchClosure = fetchClosure
        super.init()
    }
    
    public subscript(index: Int) -> Element {
        return _viewModels.value[index]
    }
    
    /// Initializes refresh action.
    ///
    /// Default implementation initializes an Action that is enabled when the receiver is,
    /// and executes `fetchClosure` with nil page.
    /// 
    /// The returned action is also bound to the receiver using `bindAction`
    public func initRefreshAction() -> Action<(), [Element], FetchError>
    {
        let action: Action<(), [Element], FetchError> = Action(enabledIf: self.enabled) { [unowned self] _ in
            self._refreshing.value = true
            return self._fetch(nil)
        }
        
        bindAction(action)
        
        return action
    }
    
    /// Initializes Fetch action.
    ///
    /// Default implementation initializes an Action that is enabled when the receiver is,
    /// and executes `fetchClosure` with `nextPage`.
    ///
    /// The returned action is also bound to the receiver using `bindAction`
    public func initFetchAction() -> Action<(), [Element], FetchError>
    {
        let action: Action<(), [Element], FetchError> = Action(enabledIf: self.enabled) { [unowned self] _ in
            if self.willFetchNextPage
            {
                self._fetchingNextPage.value = true
            }
            else
            {
                self._refreshing.value = true
            }
            return self._fetch(self.nextPage)
        }
        
        bindAction(action)
        
        return action
    }
    
    private func _fetch(page: PaginationType?) -> SignalProducer<[Element], FetchError>
    {
        return self.fetchClosure(page)
            .on(next: { [unowned self] viewModels, page in
                if self.refreshing.value
                {
                    self._viewModels.value.removeAll()
                }
                self._viewModels.value.appendContentsOf(viewModels)
                
                self._hasNextPage.value = viewModels.count > 0
                self.nextPage = page
                },
                terminated: { [unowned self] in
                    self._refreshing.value = false
                    self._fetchingNextPage.value = false
                })
            .map { $0.0 }
    }
}
