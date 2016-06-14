//
//  TestViewModel.swift
//  ReactiveSprint
//
//  Created by Ahmad Baraka on 3/21/16.
//  Copyright © 2016 ReactiveSprint. All rights reserved.
//

import ReactiveSprint

/// Generates `count` of ViewModels, each ViewModel will have title of `index + startValue`
func generateViewModels(count: Int, startValue: Int = 0) -> [TestViewModel] {
    var viewModels = [TestViewModel]()
    
    for index in 1...count {
        let viewModel = TestViewModel(title: String(index + startValue))
        viewModels.append(viewModel)
    }
    
    return viewModels
}

class TestViewModel: ViewModel {

}

func == (lhs: TestViewModel, rhs: TestViewModel) -> Bool {
    return lhs.title.value == rhs.title.value
}

extension TestViewModel: Equatable {
    
}
