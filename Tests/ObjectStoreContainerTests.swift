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
@testable import BluemixObjectStorageClientSDK_IOS
#else
#endif

class ObjectStoreContainerTests: XCTestCase {
	static var objStore: ObjectStorage?
	static var container: ObjectStorageContainer?
	
	override func setUp() {
		continueAfterFailure = false
	}

	func test1_ObjectStoreContainer(){
		let expecatation = expectationWithDescription("doneExpectation")
		
		let objStore = ObjectStorage(projectId: Consts.projectId)
		XCTAssertNotNil(objStore, "Failed to initialize ObjectStore")
		XCTAssertEqual(objStore.projectId, Consts.projectId, "ObjectStore projectId is not equal to the one initialized with")
		
		
		objStore.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler: { (error) in
			XCTAssertNil(error, "error != nil")
			ObjectStoreContainerTests.objStore = objStore
			expecatation.fulfill()
		})
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test2_CreateContainer(){
		let objStore = ObjectStoreContainerTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		
		let expecatation = expectationWithDescription("doneExpectation")

		objStore!.createContainer(name: Consts.containerName) {(error, container) in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(container, "container == nil")
			XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
			XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
			XCTAssertNotNil(container?.resource, "container.resource == nil")
			ObjectStoreContainerTests.container = container
			expecatation.fulfill()
		}
	
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test3_UpdateMetadata(){
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")

		let expecatation = expectationWithDescription("doneExpectation")
		
		let metadata:Dictionary<String, String> = [Consts.containerMetadataTestName:Consts.metadataTestValue]
		
		container!.updateMetadata(metadata: metadata) { (error) in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}

		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test4_RetrieveMetadata(){
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")
		
		let expecatation = expectationWithDescription("doneExpectation")

		container!.retrieveMetadata { (error, metadata) in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(metadata, "metadata == nil")
			XCTAssertEqual(metadata![Consts.containerMetadataTestName], Consts.metadataTestValue, "metadataTestValue != \(Consts.metadataTestValue)")
			expecatation.fulfill()
		}
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test5_StoreObject(){
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		container!.storeObject(name: Consts.objectName, data: Consts.objectData) { (error, object) in
			XCTAssertNil(error, "error != nil")
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
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")
		let expecatation = expectationWithDescription("doneExpectation")

		container!.retrieveObject(name: Consts.objectName) { (error, object) in
			XCTAssertNil(error, "error != nil")
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
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		container!.retrieveObjectsList { (error, objects) in
			XCTAssertNil(error, "error != nil")
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
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		container!.deleteObject(name: Consts.objectName) { (error) in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test9_DeleteContainer(container: ObjectStorageContainer){
		let container = ObjectStoreContainerTests.container
		XCTAssertNotNil(container, "container == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		container!.delete { (error) in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}

		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
}
