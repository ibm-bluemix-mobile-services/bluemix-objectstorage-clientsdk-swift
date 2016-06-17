/*
 *     Copyright 2016 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

import XCTest
import Foundation
#if os(iOS)
    @testable import BluemixObjectStorage
#else
#endif

class ObjectStoreTests: XCTestCase {
    
    static var objStore: ObjectStorage?
    static var container: ObjectStorageContainer?
    static var mockManager: Manager = ObjectStoreMock()
    
    
    override class func setUp() {
        self.objStore = ObjectStorage(projectId: Consts.projectId)
        self.objStore!.manager = ObjectStoreTests.mockManager
        self.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler:{(error) in
            if error != nil{
                print("Error \"connecting\" before ObjectStoreTests class")
            }else{
                print("Set up mocks for test")
            }
        })
    }
    override func setUp() {
        self.continueAfterFailure = false
    }
    
    func test1_ObjectStore(){
        let expecatation = expectationWithDescription("doneExpectation")
        
        
        XCTAssertNotNil(ObjectStoreTests.objStore, "Failed to initialize ObjectStore")
        XCTAssertEqual(ObjectStoreTests.objStore!.projectId, Consts.projectId, "ObjectStore projectId is not equal to the one initialized with")
        
        ObjectStoreTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler: { (error) in
            XCTAssertNil(error, "error != nil")
            expecatation.fulfill()
        })
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test2_UpdateMetadata(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        let metadata:Dictionary<String, String> = [Consts.accountMetadataTestName:Consts.metadataTestValue]
        ObjectStoreTests.objStore!.updateMetadata(metadata: metadata) { (error) in
            XCTAssertNil(error, "error != nil")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test3_RetrieveMetadata(){
        XCTAssertNotNil(ObjectStoreTests.objStore!, "objStore == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreTests.objStore!.retrieveMetadata { (error, metadata) in
            XCTAssertNil(error, "error != nil")
            XCTAssertNotNil(metadata, "metadata == nil")
            XCTAssertEqual(metadata![Consts.accountMetadataTestName], Consts.metadataTestValue, "metadataTestValue != \(Consts.metadataTestValue)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test4_CreateContainer(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreTests.objStore!.createContainer(name: Consts.containerName) {(error, container) in
            XCTAssertNil(error, "error != nil")
            XCTAssertNotNil(container, "container == nil")
            XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
            XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container?.resource, "container.resource == nil")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test5_RetrieveContainer(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreTests.objStore!.retrieveContainer(name: Consts.containerName) { (error, container) in
            XCTAssertNil(error, "error != nil")
            XCTAssertNotNil(container, "container == nil")
            XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
            XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container?.resource, "container.resource == nil")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test6_RetrieveContainersList(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreTests.objStore!.retrieveContainersList { (error, containers) in
            XCTAssertNil(error, "error != nil")
            XCTAssertNotNil(containers, "containers == nil")
            XCTAssertNotNil(containers?.count, "containers.count == nil")
            XCTAssertGreaterThan(Int(containers!.count), Int(0), "containers.count <= 0")
            let container = containers![0]
            XCTAssertNotNil(container.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container.resource, "container.resource == nil")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    
    func test7_DeleteContainer(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreTests.objStore!.deleteContainer(name: Consts.containerName) { (error) in
            XCTAssertNil(error, "error != nil")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
}

