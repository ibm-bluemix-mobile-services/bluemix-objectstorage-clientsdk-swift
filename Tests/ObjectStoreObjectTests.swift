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

class ObjectStoreObjectTests: XCTestCase {
	var expecatation:XCTestExpectation?

	static var objStore: ObjectStorage?
	static var container: ObjectStorageContainer?
	static var object: ObjectStorageObject?
	
	override func setUp() {
		self.continueAfterFailure = false
	}

	func test1_ObjectStore(){
		let expecatation = expectationWithDescription("doneExpectation")
		
		let objStore = ObjectStorage(projectId: Consts.projectId)
		XCTAssertNotNil(objStore, "Failed to initialize ObjectStore")
		XCTAssertEqual(objStore.projectId, Consts.projectId, "ObjectStore projectId is not equal to the one initialized with")

		objStore.connect(userId: Consts.userId, password: Consts.password, region: Consts.region, completionHandler: { (error) in
			XCTAssertNil(error, "error != nil")
			ObjectStoreObjectTests.objStore = objStore
			expecatation.fulfill()
		})
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test2_CreateContainer(){
		let expecatation = expectationWithDescription("doneExpectation")
		let objStore = ObjectStoreObjectTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		
		objStore!.createContainer(name: Consts.containerName) {(error, container) in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(container, "container == nil")
			XCTAssertEqual(container?.name, Consts.containerName, "container.name != \(Consts.containerName)")
			XCTAssertNotNil(container?.objectStore, "container.objectStore == nil")
			XCTAssertNotNil(container?.resource, "container.resource == nil")
			ObjectStoreObjectTests.container = container
			expecatation.fulfill()
		}

		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test3_StoreBigObject(){
		let expecatation = expectationWithDescription("doneExpectation")
		let container = ObjectStoreObjectTests.container
		XCTAssertNotNil(container, "container == nil")

		let bigData = Consts.bigObjectData
		print("bigObjectData.length == \(bigData.length)")
		container!.storeObject(name: Consts.objectName, data: bigData) { (error, object) in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(object, "object == nil")
			XCTAssertEqual(object?.name, Consts.objectName, "object.name != \(Consts.objectName)")
			XCTAssertNotNil(object?.container, "object.container == nil")
			XCTAssertNotNil(object?.resource, "object.resource == nil")
			XCTAssertEqual(object?.data, bigData, "object.data != Consts.bigObjectData")
			ObjectStoreObjectTests.object = object
			expecatation.fulfill()
		}
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test4_LoadBigObjectNoCaching(){
		let expecatation = expectationWithDescription("doneExpectation")
		let object = ObjectStoreObjectTests.object
		XCTAssertNotNil(object, "object == nil")
		
		object!.load(shouldCache: false) { error, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(data, "data == nil")
			XCTAssertEqual(data, Consts.bigObjectData, "data != Consts.bigObjectData")
			XCTAssertNil(object!.data, "object.data != nil")
			expecatation.fulfill()
		}
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test5_LoadObjectWithCaching(){
		let expecatation = expectationWithDescription("doneExpectation")
		let object = ObjectStoreObjectTests.object
		XCTAssertNotNil(object, "object == nil")
		
		object!.load(shouldCache: true) { error, data in
			XCTAssertNil(error, "error != nil")
			XCTAssertNotNil(data, "data == nil")
			XCTAssertEqual(data, Consts.bigObjectData, "data != Consts.bigObjectData")
			XCTAssertEqual(object!.data, Consts.bigObjectData, "object.data != Consts.objectData")
			expecatation.fulfill()
		}
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test6_UpdateMetadata(){
		let expecatation = expectationWithDescription("doneExpectation")
		let object = ObjectStoreObjectTests.object
		XCTAssertNotNil(object, "object == nil")
		
		let metadata:Dictionary<String, String> = [Consts.objectMetadataTestName:Consts.metadataTestValue]
		object!.updateMetadata(metadata: metadata) {error in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test7_RetrieveMetadata(){
		let expecatation = expectationWithDescription("doneExpectation")
		let object = ObjectStoreObjectTests.object
		XCTAssertNotNil(object, "object == nil")
		
		object!.retrieveMetadata {error, metadata in
			XCTAssertNil(error, "error != nil")
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
		let object = ObjectStoreObjectTests.object
		XCTAssertNotNil(object, "object == nil")
		
		object!.delete {error in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test9_DeleteContainer(){
		let expecatation = expectationWithDescription("doneExpectation")
		let container = ObjectStoreObjectTests.container
		XCTAssertNotNil(container, "container == nil")
		
		container!.delete {error in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
}
