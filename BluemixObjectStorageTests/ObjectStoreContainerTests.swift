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

class ObjectStoreContainerTests: XCTestCase {
    static var objStore: ObjectStorage?
    static var container: ObjectStorageContainer?
    static var mockManager: HttpManager = ObjectStoreHttpMock()
    
    
    /*
     BeforeClass setup: runs once before any of the tests
     Sets up the mocks - creates an ObjectStorage, then injects a mock 
        HttpManager (so that the http calls go through a mock and not to bluemix)
    */
    override class func setUp() {
        ObjectStoreContainerTests.objStore = ObjectStorage(projectId: Consts.projectId)
        
        if !Consts.isIntegrationTest{
            ObjectStoreContainerTests.objStore!.httpManager = ObjectStoreTests.mockManager
        }
        ObjectStoreContainerTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler:{(error) in
            if error != nil{
                //validates that our mock is working, otherwise the ObjectStorage might be talking to bluemix and actually get a connection error
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
        continueAfterFailure = false
    }
    
    func test1_ObjectStoreContainer(){
        
        let expecatation = expectationWithDescription("doneExpectation")
 
        XCTAssertNotNil(ObjectStoreContainerTests.objStore, "Failed to initialize ObjectStore")
        XCTAssertEqual(ObjectStoreContainerTests.objStore!.projectId, Consts.projectId, "ObjectStore projectId is not equal to the one initialized with")
        
        ObjectStoreContainerTests.objStore!.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler: { (error) in
            XCTAssertNil(error, "\nError connecting: \(error)")
            expecatation.fulfill()
        })
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
        ObjectStoreContainerTests.objStore!.deleteContainer(name: Consts.containerName, completionHandler:{ (error) in
            //do not fail test, this is for integration tests with bluemix, to delete any leftover containers before the other tests
            print("Error Deleting Container in test1_ObjectStoreContainer: \(error)")})
    }
    
    func test2_CreateContainer(){
        XCTAssertNotNil(ObjectStoreContainerTests.objStore, "objStore == nil")
        
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreContainerTests.objStore!.createContainer(name: Consts.containerName) {(error, container) in
            XCTAssertNil(error, "Error creating container: \(error)")
            XCTAssertNotNil(container, "container == nil")
            XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
            XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
            XCTAssertNotNil(container?.resource, "container.resource == nil")
            ObjectStoreContainerTests.container = container
            if !Consts.isIntegrationTest{
                print("Setting mock httpManager for unit tests")
                ObjectStoreContainerTests.container!.httpManager = OSContainerHttpMock() //inject the container mock
            }
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test3_UpdateMetadata(){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        
        let expecatation = expectationWithDescription("doneExpectation")
        
        let metadata:Dictionary<String, String> = [Consts.containerMetadataTestName:Consts.metadataTestValue]
        
        ObjectStoreContainerTests.container!.updateMetadata(metadata: metadata) { (error) in
            XCTAssertNil(error, "Error updating container metadata: \(error)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test4_RetrieveMetadata(){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreContainerTests.container!.retrieveMetadata { (error, metadata) in
            XCTAssertNil(error, "Error retrieving container metadata: \(error)")
            XCTAssertNotNil(metadata, "metadata == nil")
            XCTAssertEqual(metadata![Consts.containerMetadataTestName], Consts.metadataTestValue, "metadataTestValue != \(Consts.metadataTestValue)")
            expecatation.fulfill()
        }
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test5_StoreObject(){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        ObjectStoreContainerTests.container!.storeObject(name: Consts.objectName, data: Consts.objectData) { (error, object) in
            XCTAssertNil(error, "Error storing object: \(error)")
            XCTAssertNotNil(object, "object == nil")
            XCTAssertEqual(object?.name, Consts.objectName, "object.name != \(Consts.objectName)")
            XCTAssertNotNil(object?.container, "object.container == nil")
            XCTAssertNotNil(object?.resource, "object.resource == nil")
            XCTAssertEqual(object?.data, Consts.objectData, "object.data != \(Consts.objectData)")
            expecatation.fulfill()
        }
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test6_RetrieveObject(){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreContainerTests.container!.retrieveObject(name: Consts.objectName) { (error, object) in
            XCTAssertNil(error, "Error retrieving object: \(error)")
            XCTAssertNotNil(object, "object == nil")
            XCTAssertEqual(object?.name, Consts.objectName, "object.name != \(Consts.objectName)")
            XCTAssertNotNil(object?.container, "object.container == nil")
            XCTAssertNotNil(object?.resource, "object.resource == nil")
            XCTAssertEqual(object?.data, Consts.objectData, "object.data != \(Consts.objectData)")
            expecatation.fulfill()
        }
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
        
    }
    
    func test7_RetrieveObjectList(){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreContainerTests.container!.retrieveObjectsList { (error, objects) in
            XCTAssertNil(error, "Error retrieving object list: \(error)")
            XCTAssertNotNil(objects, "objects == nil")
            XCTAssertNotNil(objects?.count, "objects == nil")
            XCTAssertGreaterThan(Int(objects!.count), Int(0), "objects <= 0")
            let object = objects![0]
            XCTAssertNotNil(object.container, "object.container == nil")
            XCTAssertNotNil(object.resource, "object.resource == nil")
            expecatation.fulfill()
        }
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test8_DeleteObject(){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreContainerTests.container!.deleteObject(name: Consts.objectName) { (error) in
            XCTAssertNil(error, "Error deleting object: \(error)")
            expecatation.fulfill()
        }
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
    
    func test9_DeleteContainer(container: ObjectStorageContainer){
        XCTAssertNotNil(ObjectStoreContainerTests.container, "container == nil")
        let expecatation = expectationWithDescription("doneExpectation")
        
        ObjectStoreContainerTests.container!.delete { (error) in
            XCTAssertNil(error, "Error deleting container: \(error)")
            expecatation.fulfill()
        }
        
        waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
            XCTAssertNil(error, "Test timeout")
        }
    }
}
