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

import Foundation

/// Internal logging infrastructure
public class Logger{

	internal let name:String

	/// Set this property to true of false to control internal logging output
	public static let enabled:Bool = true
	
	/// Set this property to true or false to control internal logging output for DEBUG level only
	public static let debugLogsEnabled:Bool = true

	private static let LEVEL_INF = "INF"
	private static let LEVEL_ERR = "ERR"
	private static let LEVEL_DBG = "DBG"
	private static let LEVEL_WRN = "WRN"

	internal init(forName:String){
		self.name = forName
	}

	internal func info(text:String){
		printLog(text, level: Logger.LEVEL_INF)
	}

	internal func debug(text:String){
		if Logger.debugLogsEnabled {
			printLog(text, level: Logger.LEVEL_DBG)
		}
	}

	internal func warn(text:String){
		printLog(text, level: Logger.LEVEL_WRN)
	}

	internal func error(text:String){
		printLog(text, level: Logger.LEVEL_ERR)
	}

	private func printLog(text:String, level:String){
		if (Logger.enabled){
			print("[\(level)] [\(self.name)] \(text)")
		}
	}
}
