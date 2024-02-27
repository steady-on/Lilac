//
//  RealmRepository.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RealmSwift

struct RealmRepository<T: Object> {
    private let realm = try? Realm()
    
    func create(_ item: T) throws {
        guard let realm else { throw RealmError.failToInitialized }
        
        do {
            try realm.write { realm.add(item) }
        } catch {
            throw RealmError.failToCreate
        }
    }
    
    func read() throws -> Results<T> {
        guard let realm else { throw RealmError.failToInitialized }
        return realm.objects(T.self)
    }
    
    func update(completion: @escaping () -> Void) throws {
        guard let realm else { throw RealmError.failToInitialized }
        
        do {
            try realm.write { completion() }
        } catch {
            throw RealmError.failToUpdate
        }
    }
    
    func delete(_ item: T) throws {
        guard let realm else { throw RealmError.failToInitialized }
        
        do {
            try realm.write { realm.delete(item) }
        } catch {
            throw RealmError.failToDelete
        }
    }
}
