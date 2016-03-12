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
    typealias PaginationType
    typealias FetchError: ViewModelErrorType
    
    var refreshing: AnyProperty<Bool> { get }
    var fetchingNextPage: AnyProperty<Bool> { get }
    var hasNextPage: AnyProperty<Bool> { get }
    
    var nextPage: PaginationType? { get }
    
    var refreshAction: Action<(), [Element], FetchError> { get }
    var fetchAction: Action<(), [Element], FetchError> { get }
    
    func fetchIfNeeded()
}

public extension FetchedArrayViewModelType
{
    private var willFetchNextPage: Bool {
        return nextPage != nil
    }
    
    public func fetchIfNeeded()
    {
        if willFetchNextPage && hasNextPage.value
        {
            fetchAction.apply().start()
        }
    }
}

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
    
    public let fetchBlock: PaginationType? -> SignalProducer<([Element], PaginationType?), FetchError>
    private(set) public lazy var refreshAction: Action<(), [Element], FetchError> = self.createRefreshAction()
    private(set) public lazy var fetchAction: Action<(), [Element], FetchError> = self.createfetchAction()
    
    public init(_ fetchBlock: PaginationType? -> SignalProducer<([Element], PaginationType?), FetchError>)
    {
        self.fetchBlock = fetchBlock
        super.init()
    }
    
    public subscript(index: Int) -> Element {
        return _viewModels.value[index]
    }
    
    public func createRefreshAction() -> Action<(), [Element], FetchError>
    {
        let action: Action<(), [Element], FetchError> = Action(enabledIf: self.enabled) { [unowned self] _ in
            self._refreshing.value = true
            return self._fetch(nil)
        }
        
        bindAction(action)
        
        return action
    }
    
    public func createfetchAction() -> Action<(), [Element], FetchError>
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
        return self.fetchBlock(page)
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
