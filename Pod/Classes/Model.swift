//
//  Model.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/1/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// Represents a Model type.
public protocol AnyModel
{
    
}

/// Represents a Model that can be saved.
public protocol ModelSaving: AnyModel
{
    typealias SaveInput
    typealias SaveError: ErrorType
    
    func save(input: SaveInput) -> SignalProducer<Self, SaveError>
}

/// Represents a Model that can be fetched.
public protocol ModelFetching: AnyModel
{
    typealias FetchInput
    typealias FetchError: ErrorType
    
    func fetch(input: FetchInput) -> SignalProducer<Self, FetchError>
}

/// Represents a Model that can be deleted.
public protocol ModelDeleting: AnyModel
{
    typealias DeleteInput
    typealias DeleteError: ErrorType
    
    func delete(input: DeleteInput) -> SignalProducer<Self, DeleteError>
}
