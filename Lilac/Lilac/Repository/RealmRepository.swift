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
    
    /// realm에 item 생성 후 저장
    func create(_ item: T) {
        do {
            try realm?.write { realm!.add(item) }
        } catch {
            print("Realm Create Error:", error)
        }
    }
    
    /// realm table 불러오기
    func read() -> Results<T> {
        print(realm?.configuration.fileURL)
        return realm!.objects(T.self)
    }
    
    /// item 수정
    func update(completion: @escaping () -> Void) {
        do {
            try realm?.write { completion() }
        } catch {
            print("Realm Update Error:", error)
        }
    }
    
    /// item 삭제
    func delete(_ item: T) {
        do {
            try realm?.write { realm!.delete(item) }
        } catch {
            print("Realm Delete Error:", error)
        }
    }
    
    /// 여러 item 삭제
    func delete(_ items: Results<T>) {
        do {
            try realm?.write { realm!.delete(items) }
        } catch {
            print("Realm Delete Error:", error)
        }
    }
}
