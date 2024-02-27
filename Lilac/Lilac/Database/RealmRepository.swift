//
//  RealmRepository.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RealmSwift

final class RealmRepository {
    private let realm = try? Realm()
    
    func create<T: Object>(_ item: T) throws {
        guard let realm else { throw RealmError.failToInitialized }
        
        do {
            try realm.write { realm.add(item) }
        } catch {
            throw RealmError.failToCreate
        }
    }
    
    func read<T: Object>(for type: T.Type) throws -> Results<T> {
        guard let realm else { throw RealmError.failToInitialized }
        let results = realm.objects(type.self)
        
        return realm.objects(type.self)
    }
    
    func update(completion: @escaping () -> Void) throws {
        guard let realm else { throw RealmError.failToInitialized }
        
        do {
            try realm.write { completion() }
        } catch {
            throw RealmError.failToUpdate
        }
    }
    
    func delete<T: Object>(_ item: T) throws {
        guard let realm else { throw RealmError.failToInitialized }
        
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            throw RealmError.failToDelete
        }
    }
}
