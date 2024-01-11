//
//  AlertAction.swift
//  Lilac
//
//  Created by Roen White on 1/11/24.
//

import UIKit

struct AlertAction {
    let title: String
    let style: Style
    let handler: UIAction?
    
    init(title: String, style: Style, handler: UIAction? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    enum Style {
        case `default`
        case cancel
        case destructive
    }
}
