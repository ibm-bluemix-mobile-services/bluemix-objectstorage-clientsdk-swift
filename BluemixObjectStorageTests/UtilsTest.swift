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

class UtilsTests: XCTestCase {
	func testUrlPathEncode(){
		let encoded = Utils.urlPathEncode(text: "a b c d привет")
		XCTAssertEqual(encoded, "a%20b%20c%20d%20%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82")
	}
	
	func testCreateHeaderDictionary(){
		var headers = Utils.createHeaderDictionary(authToken: "zzz")
		XCTAssertEqual(headers["X-Auth-Token"], "zzz")
		headers = Utils.createHeaderDictionary(authToken: "bbb", additionalHeaders: ["ccc":"ddd","eee":"fff"])
		XCTAssertEqual(headers["X-Auth-Token"], "bbb")
		XCTAssertEqual(headers["ccc"], "ddd")
		XCTAssertEqual(headers["eee"], "fff")
	}	
}
