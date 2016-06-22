/*
 *     Copyright 2016 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

import XCTest
import Foundation
#if os(iOS)
    @testable import BluemixObjectStorage
#else
#endif

class ObjectStoreObjectTests: XCTestCase {
    var expecatation:XCTestExpectation?
    
    static var objStore: ObjectStorage?
    static var container: ObjectStorageContainer?
    static var object: ObjectStorageObject?
    static var mockManager: HttpManager = ObjectStoreHttpMock()
    
    
    /*
     BeforeClass setup: runs once before any of the tests
     Sets up the mocks - creates an ObjectStorage, then injects a mock
     HttpManager (so that the http calls go through a mock and not to bluemix)
     */
    override class func setUp() {
        ObjectStoreObjectTests.objStore = ObjectStorage(projectId: Consts.projectId)
        
        if !Consts.isIntegrationTest{
            ObjectStoreObjectTests.objStore!.httpManager = ObjectStoreTests.mockManager
        }
        ObjectStoreObjectTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler:{(error) in
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
        let expecatation = expectationWithDescription("doneExpectation")
        
        XCTAssertNotNil(ObjectStoreObjectTests.objStore, "Failed to initialize ObjectStore")
        XCTAssertEqual(ObjectStoreObjectTests.objStore!.projectId, Consts.projectId, "ObjectStore projectId is not equal to the one initialized with")
        
        ObjectStoreObjectTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler: { (error) in
            XCTAssertNil(error, "Error connecting to objectStore: \(error)")
            expecatation.fulfill()
        })
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test2_CreateContainer(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.objStore, "objStore == nil")
        
        ObjectStoreObjectTests.objStore!.createContainer(name: Consts.containerName) {(error, container) in
            XCTAssertNil(error, "Error creating container: \(error)")
            XCTAssertNotNil(container, "container == nil")
            XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
            XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container?.resource, "container.resource == nil")
            ObjectStoreObjectTests.container = container
            if !Consts.isIntegrationTest{
                ObjectStoreObjectTests.container!.httpManager = OSContainerHttpMock() //inject the container mock
            }
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test3_StoreBigObject(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.container, "container == nil")
        
        let bigData = Consts.bigObjectData
        print("bigObjectData.length == \(bigData.length)")
        ObjectStoreObjectTests.container!.storeObject(name: Consts.objectName, data: bigData) { (error, object) in
            XCTAssertNil(error, "Error storing object: \(error)")
            XCTAssertNotNil(object, "object == nil")
            XCTAssertEqual(object?.name, Consts.objectName, "object.name != \(Consts.objectName)")
            XCTAssertNotNil(object?.container, "object.container == nil")
            XCTAssertNotNil(object?.resource, "object.resource == nil")
            XCTAssertEqual(object?.data, bigData, "object.data != Consts.bigObjectData")
            ObjectStoreObjectTests.object = object
            if !Consts.isIntegrationTest{
                let mang = OSObjectHttpMock()
                mang.data = object?.data
                ObjectStoreObjectTests.object!.httpManager = mang
            }
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test4_LoadBigObjectNoCaching(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.object, "object == nil")
        
        ObjectStoreObjectTests.object!.load(shouldCache: false) { error, data in
            XCTAssertNil(error, "Error loading object: \(error)")
            XCTAssertNotNil(data, "data == nil")
            XCTAssertEqual(data, Consts.bigObjectData, "data != Consts.bigObjectData")
            XCTAssertNil(ObjectStoreObjectTests.object!.data, "object.data != nil")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test5_LoadObjectWithCaching(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.object, "object == nil")
        
        ObjectStoreObjectTests.object!.load(shouldCache: true) { error, data in
            XCTAssertNil(error, "Error loading object: \(error)")
            XCTAssertNotNil(data, "data == nil")
            XCTAssertEqual(data, Consts.bigObjectData, "data != Consts.bigObjectData")
            XCTAssertEqual(ObjectStoreObjectTests.object!.data, Consts.bigObjectData, "object.data != Consts.objectData")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test6_UpdateMetadata(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.object, "object == nil")
        
        let metadata:Dictionary<String, String> = [Consts.objectMetadataTestName:Consts.metadataTestValue]
        ObjectStoreObjectTests.object!.updateMetadata(metadata: metadata) {error in
            XCTAssertNil(error, "Error updating object metadata: \(error)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test7_RetrieveMetadata(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.object, "object == nil")
        
        ObjectStoreObjectTests.object!.retrieveMetadata {error, metadata in
            XCTAssertNil(error, "Error retrieving object metadata")
            XCTAssertNotNil(metadata, "metadata == nil")
            XCTAssertEqual(metadata![Consts.objectMetadataTestName], Consts.metadataTestValue, "metadataTestValue != \(Consts.metadataTestValue)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    
    func test8_DeleteObject(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.object, "object == nil")
        
        ObjectStoreObjectTests.object!.delete {error in
            XCTAssertNil(error, "Error deleting object: \(error)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test9_DeleteContainer(){
        let expecatation = expectationWithDescription("doneExpectation")
        XCTAssertNotNil(ObjectStoreObjectTests.container, "container == nil")
        
        ObjectStoreObjectTests.container!.delete {error in
            XCTAssertNil(error, "Error deleting container: \(error)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
}