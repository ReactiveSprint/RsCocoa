//
//  ModelViewModel.swift
//  Pods
//
//  Created by Ahmad Baraka on 3/1/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

/// Represents ViewModel that wraps a Model.
///
/// Must be implemented as class type, to support weak references.
public protocol ModelViewModelType: class, ViewModelType
{
    /// Type of Model
    typealias Model: AnyModel
    
    var model: Model { get }
}

/// Implementation of `ModelViewModelType`
public class ModelViewModel<Model: AnyModel>: ViewModel, ModelViewModelType
{
    /// Returns the Model object wrapped in the receiver.
    public let model: Model
    
    /// Initializes a ViewModel with `title and model.`
    ///
    /// - Parameter title: The title for ViewModel.
    /// - Parameter model: Model to be wrapped.
    public init(title: String?, _ model: Model)
    {
        self.model = model
        super.init(title: title)
    }
    
    /// Initializes a ViewModel with `model.`
    ///
    /// - Parameter model: Model to be wrapped.
    public convenience init(_ model: Model)
    {
        self.init(title: nil, model)
    }
}

public extension ModelViewModelType where Model: ModelSaving
{
    private func _createSaveAction() -> Action<Model.SaveInput, Model, Model.SaveError>
    {
        return Action(enabledIf: self.enabled) { [unowned self] in self.model.save($0) }
    }
    
    /// An action to save the wrapped model.
    ///
    /// This action is `enabledIf: self.enabled` and is bound to the receiver using `bindAction(action:)`
    public func createSaveAction() -> Action<Model.SaveInput, Model, Model.SaveError>
    {
        let action = _createSaveAction()
        bindAction(action)
        return action
    }
}

public extension ModelViewModelType where Model: ModelSaving, Model.SaveError: ViewModelErrorType
{
    /// An action to save the wrapped model.
    ///
    /// This action is `enabledIf: self.enabled` and is bound to the receiver using `bindAction(action:)`
    public func createSaveAction() -> Action<Model.SaveInput, Model, Model.SaveError>
    {
        let action = _createSaveAction()
        bindAction(action)
        return action
    }
}

public extension ModelViewModelType where Model: ModelFetching
{
    private func _createFetchAction() -> Action<Model.FetchInput, Model, Model.FetchError>
    {
        return Action(enabledIf: self.enabled) { [unowned self] in self.model.fetch($0) }
    }
    
    /// An action to fetch the wrapped model.
    ///
    /// This action is `enabledIf: self.enabled` and is bound to the receiver using `bindAction(action:)`
    public func createFetchAction() -> Action<Model.FetchInput, Model, Model.FetchError>
    {
        let action = _createFetchAction()
        bindAction(action)
        return action
    }
}

public extension ModelViewModelType where Model: ModelFetching, Model.FetchError: ViewModelErrorType
{
    /// An action to fetch the wrapped model.
    ///
    /// This action is `enabledIf: self.enabled` and is bound to the receiver using `bindAction(action:)`
    public func createFetchAction() -> Action<Model.FetchInput, Model, Model.FetchError>
    {
        let action = _createFetchAction()
        bindAction(action)
        return action
    }
}

public extension ModelViewModelType where Model: ModelDeleting
{
    private func _createDeleteAction() -> Action<Model.DeleteInput, Model, Model.DeleteError>
    {
        return Action(enabledIf: self.enabled) { [unowned self] in self.model.delete($0) }
    }
    
    /// An action to delete the wrapped model.
    ///
    /// This action is `enabledIf: self.enabled` and is bound to the receiver using `bindAction(action:)`
    public func createDeleteAction() -> Action<Model.DeleteInput, Model, Model.DeleteError>
    {
        let action = _createDeleteAction()
        bindAction(action)
        return action
    }
}

public extension ModelViewModelType where Model: ModelDeleting, Model.DeleteError: ViewModelErrorType
{
    /// An action to delete the wrapped model.
    ///
    /// This action is `enabledIf: self.enabled` and is bound to the receiver using `bindAction(action:)`
    public func createDeleteAction() -> Action<Model.DeleteInput, Model, Model.DeleteError>
    {
        let action = _createDeleteAction()
        bindAction(action)
        return action
    }
}
