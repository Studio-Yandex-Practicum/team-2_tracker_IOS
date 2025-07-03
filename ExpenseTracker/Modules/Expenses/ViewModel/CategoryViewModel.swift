//
//  CategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Ольга Чушева on 07.05.2025.
//

import Foundation

final class CategoryViewModel {
    
    private var categorys: [CategoryMain] = CategoryProvider.baseCategories
   
    func addCategory(category: CategoryMain) -> [CategoryMain] {
        categorys.append(category)
        return categorys
    }
}
