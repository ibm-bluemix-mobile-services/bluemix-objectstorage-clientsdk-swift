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
    static var mockManager: HttpManager = ObjectStoreHttpMock()
    
    
    /*
     BeforeClass setup: runs once before any of the tests
     Sets up the mocks - creates an ObjectStorage, then injects a mock
     HttpManager (so that the http calls go through a mock and not to bluemix)
     */
    override class func setUp() {
        ObjectStoreTests.objStore = ObjectStorage(projectId: Consts.projectId)
        
        if !Consts.isIntegrationTest{
            ObjectStoreTests.objStore!.httpManager = ObjectStoreTests.mockManager
        }
        ObjectStoreTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler:{(error) in
            if error != nil{
                print("Error \"connecting\" before ObjectStoreTests class")
            }else{
                if Consts.isIntegrationTest{
                    print("ObjectStore connection Successful")
                }else{
                    print("Set up mocks for test")
                }
            }
        })
    }
    override func setUp() {
        self.continueAfterFailure = false
    }
    
    func test1_ObjectStore(){
        let expecatation = expectation(description: "doneExpectation")
        
        XCTAssertNotNil(ObjectStoreTests.objStore, "Failed to initialize ObjectStore")
        XCTAssertEqual(ObjectStoreTests.objStore!.projectId, Consts.projectId, "ObjectStore projectId is not equal to the one initialized with")
        
        ObjectStoreTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler: { (error) in
            XCTAssertNil(error, "Error connecting to objectStore: \(String(describing: error))")
            expecatation.fulfill()
        })
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test2_UpdateMetadata(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectation(description: "doneExpectation")
        let metadata:[String: String] = [Consts.accountMetadataTestName:Consts.metadataTestValue]
        ObjectStoreTests.objStore!.update(metadata: metadata) { (error) in
            XCTAssertNil(error, "Error updating objectStore metadata: \(String(describing: error))")
            expecatation.fulfill()
        }
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test3_RetrieveMetadata(){
        XCTAssertNotNil(ObjectStoreTests.objStore!, "objStore == nil")
        let expecatation = expectation(description: "doneExpectation")
        
        ObjectStoreTests.objStore!.retrieveMetadata { (error, metadata) in
            XCTAssertNil(error, "Error retrieving objectStore metadata: \(String(describing: error))")
            XCTAssertNotNil(metadata, "metadata == nil")
            XCTAssertEqual(metadata![Consts.accountMetadataTestName], Consts.metadataTestValue, "metadataTestValue != \(Consts.metadataTestValue)")
            expecatation.fulfill()
        }
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test4_CreateContainer(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectation(description: "doneExpectation")
        
        ObjectStoreTests.objStore!.create(container: Consts.containerName) {(error, container) in
            XCTAssertNil(error, "Error creating container: \(String(describing: error))")
            XCTAssertNotNil(container, "container == nil")
            XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
            XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container?.resource, "container.resource == nil")
            expecatation.fulfill()
        }
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test5_RetrieveContainer(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectation(description: "doneExpectation")
        
        ObjectStoreTests.objStore!.retrieve(container: Consts.containerName) { (error, container) in
            XCTAssertNil(error, "Error retrieving container: \(String(describing: error))")
            XCTAssertNotNil(container, "container == nil")
            XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
            XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container?.resource, "container.resource == nil")
            expecatation.fulfill()
        }
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test6_RetrieveContainersList(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectation(description: "doneExpectation")
        
        ObjectStoreTests.objStore!.retrieveContainersList { (error, containers) in
            XCTAssertNil(error, "Error retrieving container list: \(String(describing: error))")
            XCTAssertNotNil(containers, "containers == nil")
            XCTAssertNotNil(containers?.count, "containers.count == nil")
            XCTAssertGreaterThan(Int(containers!.count), Int(0), "containers.count <= 0")
            let container = containers![0]
            XCTAssertNotNil(container.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container.resource, "container.resource == nil")
            expecatation.fulfill()
        }
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    
    func test7_DeleteContainer(){
        XCTAssertNotNil(ObjectStoreTests.objStore, "objStore == nil")
        let expecatation = expectation(description: "doneExpectation")
        
        ObjectStoreTests.objStore!.delete(container: Consts.containerName) { (error) in
            XCTAssertNil(error, "Error deleting container: \(String(describing: error))")
            expecatation.fulfill()
        }
        
        waitForExpectations(timeout: Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
}

