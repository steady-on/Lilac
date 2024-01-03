//
//  Font+.swift
//  Lilac
//
//  Created by Roen White on 1/4/24.
//

import SwiftUI

extension Font {
    enum Typography {
        case title1
        case title2
        case bodyBold
        case body
        case caption
        
        var size: CGFloat {
            switch self {
            case .title1: return 22
            case .title2: return 14
            case .bodyBold: return 13
            case .body: return 13
            case .caption: return 12
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .title1, .title2 , .bodyBold:
                return .bold
            case .body, .caption:
                return .regular
            }
        }
    }
}
