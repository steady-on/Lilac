//
//  RealmRepository.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RealmSwift

struct RealmRepository<T: Object> {
    private var realm: Realm? {
        do {
            return try Realm()
        } catch {
            print("Realm initialized Error!")
            return nil
        }
    }
    
    func create(_ item: T) {
        do {
            try realm?.write { realm!.add(item) }
        } catch {
            print("Realm Create Error:", error)
        }
    }
    
    func read() -> Results<T>? {
        return realm?.objects(T.self)
    }
    
    func update(completion: @escaping () -> Void) {
        do {
            try realm?.write { completion() }
        } catch {
            print("Realm Update Error:", error)
        }
    }
    
    func delete(_ item: T) {
        do {
            try realm?.write { realm!.delete(item) }
        } catch {
            print("Realm Delete Error:", error)
        }
    }
}
