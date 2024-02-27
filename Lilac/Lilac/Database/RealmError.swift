//
//  RealmError.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation

enum RealmError: Error {
    case failToInitialized
    case failToCreate
    case failToUpdate
    case failToDelete
    case failToQuery
}
