//
//  FetchedArrayViewModel.Swift
//  Pods
//
//  Created by Ahmad Baraka on 3/2/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveCocoa
import Result

/// Non-generic FetchedArrayViewModelType used with Cocoa.
public protocol CocoaFetchedArrayViewModelType: CocoaArrayViewModelType
{
    /// Whether the ViewModel is refreshing.
    var refreshing: AnyProperty<Bool> { get }
    
    /// Whether the ViewModel is fetching next page and is not refreshing.
    var fetchingNextPage: AnyProperty<Bool> { get }
    
    /// Whether the ViewModel has next page.
    var hasNextPage: AnyProperty<Bool> { get }
    
    var refreshCocoaAction: CocoaAction { get }
    
    var fetchCocoaAction: CocoaAction { get }

    var fetchIfNeededCocoaAction: CocoaAction { get }
}

/// ArrayViewModel which its array is lazily fetched, or even paginated.
public protocol FetchedArrayViewModelType: ArrayViewModelType, CocoaFetchedArrayViewModelType
{
    associatedtype FetchInput
    associatedtype FetchOutput
    associatedtype PaginationType
    associatedtype FetchError: ViewModelErrorType
    
    /// Next Page
    var nextPage: PaginationType? { get }
    
    /// Action which refreshes ViewModels.
    var refreshAction: Action<FetchInput, FetchOutput, FetchError> { get }
    
    /// Action which fetches ViewModels.
    ///
    /// If `nextPage` is nil, then this action will refresh, else this action should fetch next page.
    var fetchAction: Action<FetchInput, FetchOutput, FetchError> { get }
    
    /// Applies `fetchAction` only if next page is availabe or returns `SignalProducer.empty`
    var fetchIfNeededAction: Action<FetchInput, FetchOutput, ActionError<FetchError>> { get }
}

public extension FetchedArrayViewModelType
{
    private var willFetchNextPage: Bool {
        return nextPage != nil
    }
    
    public func fetchIfNeeded(input: FetchInput) -> SignalProducer<FetchOutput, ActionError<FetchError>>
    {
        if willFetchNextPage && hasNextPage.value
        {
            return fetchAction.apply(input)
        }
        
        return SignalProducer.empty
    }
}

public extension FetchedArrayViewModelType
{
    public var fetchCocoaAction: CocoaAction { return fetchAction.unsafeCocoaAction }
    
    public var refreshCocoaAction: CocoaAction { return refreshAction.unsafeCocoaAction }
    
    public var fetchIfNeededCocoaAction: CocoaAction { return fetchIfNeededAction.unsafeCocoaAction }
}

/// An implementation of FetchedArrayViewModelType that fetches ViewModels by calling `fetchClosure.`
public class FetchedArrayViewModel<Element: ViewModelType, PaginationType, FetchError: ViewModelErrorType>: ViewModel, FetchedArrayViewModelType
{
    private let _viewModels: MutableProperty<[Element]> = MutableProperty([])
    public var viewModels: [Element] {
        return _viewModels.value
    }
    
    private(set) public lazy var count: AnyProperty<Int> = AnyProperty(initialValue: 0, producer: self._viewModels.producer.map { $0.count })
    
    public let localizedEmptyMessage = MutableProperty<String?>(nil)
    
    private let _refreshing = MutableProperty(false)
    private(set) public lazy var refreshing: AnyProperty<Bool> = AnyProperty(self._refreshing)
    
    private let _fetchingNextPage = MutableProperty(false)
    private(set) public lazy var fetchingNextPage: AnyProperty<Bool> = AnyProperty(self._fetchingNextPage)
    
    private let _hasNextPage = MutableProperty(true)
    private(set) public lazy var hasNextPage: AnyProperty<Bool> = AnyProperty(self._hasNextPage)
    
    private(set) public var nextPage: PaginationType? = nil
    
    public let fetchClosure: PaginationType? -> SignalProducer<(PaginationType?, [Element]), FetchError>
    private(set) public lazy var refreshAction: Action<(), [Element], FetchError> = self.initRefreshAction()
    private(set) public lazy var fetchAction: Action<(), [Element], FetchError> = self.initFetchAction()
    
    private(set) public lazy var fetchIfNeededAction: Action<(), [Element], ActionError<FetchError>> = { _ in
        
        let action = Action<(), [Element], ActionError<FetchError>>(enabledIf: self.enabled) { [unowned self] _ in
            return self.fetchIfNeeded()
        }
        
        action.unsafeCocoaAction = CocoaAction(action, input: ())
        
        return action
    }()
    
    /// Initializes an instance with `fetchClosure`
    ///
    /// - Parameter fetchClosure: A closure which is called each time `refreshAction` or `fetchAction`
    /// are called passing latest PaginationType
    /// and returns a `SignalProducer` which sends PaginationType and an array of `Element`.
    /// If the returned SignalProducer sends nil PaginationType, then no pagination will be handled.
    public init(_ fetchClosure: PaginationType? -> SignalProducer<(PaginationType?, [Element]), FetchError>)
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
    /// `CocoaAction.unsafeCocoaAction` is set with a safe one ignoring any input.
    ///
    /// The returned action is also bound to the receiver using `bindAction`
    public func initRefreshAction() -> Action<(), [Element], FetchError>
    {
        let action: Action<(), [Element], FetchError> = Action(enabledIf: self.enabled) { [unowned self] _ in
            self._refreshing.value = true
            return self._fetch(nil)
        }
        
        bindAction(action)
        
        action.unsafeCocoaAction = CocoaAction(action, input: ())
        
        return action
    }
    
    /// Initializes Fetch action.
    ///
    /// Default implementation initializes an Action that is enabled when the receiver is,
    /// and executes `fetchClosure` with `nextPage`.
    ///
    /// `CocoaAction.unsafeCocoaAction` is set with a safe one ignoring any input.
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
        
        action.unsafeCocoaAction = CocoaAction(action, input: ())
        
        return action
    }
    
    private func _fetch(page: PaginationType?) -> SignalProducer<[Element], FetchError>
    {
        return self.fetchClosure(page)
            .on(next: { [unowned self] page, viewModels in
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
            .map { $0.1 }
    }

    public func indexOf(predicate: Element -> Bool) -> Int?
    {
        return viewModels.indexOf(predicate)
    }
}
