//
//  Priorities.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/17/21.
//

import Foundation
import SwiftUI

struct Priorities {
    static let lowPriority = 0
    static let mediumPriority = 1
    static let highPriority = 2
    
    static let lowPriorityColor = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 1, alpha: 1)
    static let mediumPriorityColor = #colorLiteral(red: 0, green: 0.8156862745, blue: 0, alpha: 1)
    static let highPriorityColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    
    static func getColor(for priority: Int) -> Color {
        switch priority {
        case lowPriority:
            return Color(lowPriorityColor)
        case mediumPriority:
            return Color(mediumPriorityColor)
        case highPriority:
            return Color(highPriorityColor)
        default:
            return Color(mediumPriorityColor)
        }
    }
}
