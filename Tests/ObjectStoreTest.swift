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

class ObjectStoreTests: XCTestCase {
	
	static var objStore: ObjectStorage?
	static var container: ObjectStorageContainer?

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
			ObjectStoreTests.objStore = objStore
			expecatation.fulfill()
		})
		
		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test2_UpdateMetadata(){
		let objStore = ObjectStoreTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		let metadata:Dictionary<String, String> = [Consts.accountMetadataTestName:Consts.metadataTestValue]
		objStore!.updateMetadata(metadata: metadata) { (error) in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}

		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
	
	func test3_RetrieveMetadata(){
		let objStore = ObjectStoreTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		objStore!.retrieveMetadata { (error, metadata) in
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
		let objStore = ObjectStoreTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		objStore!.createContainer(name: Consts.containerName) {(error, container) in
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
		let objStore = ObjectStoreTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		objStore!.retrieveContainer(name: Consts.containerName) { (error, container) in
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
		let objStore = ObjectStoreTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		let expecatation = expectationWithDescription("doneExpectation")
		
		objStore!.retrieveContainersList { (error, containers) in
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
		let objStore = ObjectStoreTests.objStore
		XCTAssertNotNil(objStore, "objStore == nil")
		let expecatation = expectationWithDescription("doneExpectation")

		objStore!.deleteContainer(name: Consts.containerName) { (error) in
			XCTAssertNil(error, "error != nil")
			expecatation.fulfill()
		}

		waitForExpectationsWithTimeout(Consts.testTimeout) { (error) in
			XCTAssertNil(error, "Test timeout")
		}
	}
}

