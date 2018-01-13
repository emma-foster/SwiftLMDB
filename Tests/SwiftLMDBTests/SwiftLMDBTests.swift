//
//  SwiftLMDBTests.swift
//  SwiftLMDBTests
//
//  Created by August Heegaard on 29/09/2016.
//  Copyright © 2016 August Heegaard. All rights reserved.
//

import XCTest
import Foundation
@testable import SwiftLMDB

class SwiftLMDBTests: XCTestCase {

    static let envPath: String = {

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let envURL = tempURL.appendingPathComponent("SwiftLMDBTests/")
        
        do {
            try FileManager.default.createDirectory(at: envURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("Could not create DB dir: \(error)")
        }
        
        return envURL.path

    }()
    
    var envPath: String { return SwiftLMDBTests.envPath }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
    
    override class func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        try? FileManager.default.removeItem(atPath: envPath)
        
    }
    
    func testGetLMDBVersion() {
        XCTAssert(SwiftLMDB.version != (0, 0, 0), "Unable to get LMDB major version.")
    }
    
    func testCreateEnvironment() {
        
        do {
            _ = try Environment(path: envPath, flags: [], maxDBs: 32, maxReaders: 126, mapSize: 10485760)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
    }
    
    func testCreateUnnamedDatabase() {
        
        do {
            let environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            _ = try environment.openDatabase(named: nil, flags: [.create])
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

    }
    
    func testHasKey() {
        
        let environment: Environment
        let database: Database
        
        do {
            environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            database = try environment.openDatabase(named: "db1", flags: [.create])
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Put a value
        let value = "Hello world!".data(using: .utf8)!
        let key = "hv1".data(using: .utf8)!
        
        do {
            try database.put(value: value, forKey: key)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Get the value
        do {
            
            let hasValue1 = try database.hasValue(forKey: key)
            let hasValue2 = try database.hasValue(forKey: "hv2".data(using: .utf8)!)
            
            XCTAssertEqual(hasValue1, true, "A value has been set for this key. Result should be true.")
            XCTAssertEqual(hasValue2, false, "No value has been set for this key. Result should be false.")
            
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
    }
    
    func testPutGetString() {
        
        let environment: Environment
        let database: Database
        
        do {
            environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            database = try environment.openDatabase(named: "db1", flags: [.create])
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Put a value
        let value = "Hello world!".data(using: .utf8)!
        let key = "hv1".data(using: .utf8)!
        
        do {
            try database.put(value: value, forKey: key)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Get the value
        do {
            
            let fetchedValue = try database.get(forKey: key)
            
            XCTAssertEqual(value, fetchedValue, "The returned value does not match the one that was set.")
            
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
    }
    
    func testEmptyKey() {

        let environment: Environment
        let database: Database

        do {
            environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            database = try environment.openDatabase(named: "db1", flags: [.create])
            
            
            
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Put a value
        do {
            try database.put(value: "test".data(using: .utf8)!, forKey: "".data(using: .utf8)!)
        } catch {
            
            return
        }
        
        XCTFail("The put operation above is expected to fail.")

    }
    
    func testDelete() {
        
        let environment: Environment
        let database: Database
        
        do {
            environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            database = try environment.openDatabase(named: "db1", flags: [.create])
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Put a value
        do {
            try database.put(value: "Hello world!".data(using: .utf8)!, forKey: "deleteTest".data(using: .utf8)!)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Delete the value.
        do {
            try database.deleteValue(forKey: "deleteTest".data(using: .utf8)!)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Get the value
        do {
            let retrievedData = try database.get(forKey: "deleteTest".data(using: .utf8)!)
            
            XCTAssertNil(retrievedData, "Value still present after delete.")

        } catch {
            XCTFail(error.localizedDescription)
            return
        }

    }
    
    func testDropDatabase() {
        
        let environment: Environment
        var database: Database!
        
        // Open a new database, creating it in the process.
        do {
            environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            database = try environment.openDatabase(named: "dropTest", flags: [.create])
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Close the database and drop it.
        do {
            
            // Drop the database and get rid of the reference, so that the handle is closed.
            try database.drop()
            database = nil

        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Attempt to open a database with the same name. We aren't passing in the .create flag, so this action should ideally fail, because it means that the database was dropped successfully.
        do {
            database = try environment.openDatabase(named: "dropTest")
        } catch {

            // The desired outcome is that the database is not found.
            if let lmdbError = error as? LMDBError {
                
                switch lmdbError {
                case .notFound: return
                default: break
                }
                
            }
            
            XCTFail(error.localizedDescription)
            return

            
        }
        
        XCTFail("The database was not dropped.")
        return
        
    }
    
    func testEmptyDatabase() {
        
        let environment: Environment
        var database: Database!
        
        // Open a new database, creating it in the process.
        do {
            environment = try Environment(path: envPath, flags: [], maxDBs: 32)
            database = try environment.openDatabase(named: "emptyTest", flags: [.create])
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Put a value
        let key = "test".data(using: .utf8)!
        do {
            try database.put(value: "Hello world!".data(using: .utf8)!, forKey: key)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Empty the database.
        do {
            try database.empty()
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Get the value. We want the result to be nil, because the database was emptied.
        do {
            let retrievedData = try database.get(forKey: key)
            
            XCTAssertNil(retrievedData, "Value still present after database being emptied.")
            
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        
    }
    
    static var allTests : [(String, (SwiftLMDBTests) -> () throws -> Void)] {
        return [
            ("testGetLMDBVersion", testGetLMDBVersion),
            ("testCreateEnvironment", testCreateEnvironment),
            ("testCreateUnnamedDatabase", testCreateUnnamedDatabase),
            ("testHasKey", testHasKey),
            ("testPutGetString", testPutGetString),
            ("testEmptyKey", testEmptyKey),
            ("testDelete", testDelete),
            ("testDropDatabase", testDropDatabase),
            ("testEmptyDatabase", testEmptyDatabase),
        ]
    }

    
}
