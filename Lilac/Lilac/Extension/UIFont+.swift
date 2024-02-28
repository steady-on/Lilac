//
//  UIFont+.swift
//  Lilac
//
//  Created by Roen White on 1/5/24.
//

import UIKit

extension UIFont {
    enum Style {
        case title1
        case title2
        case bodyBold
        case body
        case caption1
        case caption2
        
        var size: CGFloat {
            switch self {
            case .title1: return 22
            case .title2: return 14
            case .bodyBold, .body: return 13
            case .caption1: return 12
            case .caption2: return 11
            }
        }
        
        var lineHeight: CGFloat {
            switch self {
            case .title1: return 30
            case .title2: return 20
            case .bodyBold, .body, .caption1, .caption2: return 18
            }
        }
        
        var weight: Weight {
            switch self {
            case .title1, .title2, .bodyBold: return .bold
            case .body, .caption1, .caption2: return .regular
            }
        }
    }
    
    static func brandedFont(_ style: Style) -> UIFont {
        return .systemFont(ofSize: style.size, weight: style.weight)
    }
}
