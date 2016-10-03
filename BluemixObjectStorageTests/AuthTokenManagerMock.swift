//
//  AuthTokenHttpMock.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

@testable import BluemixObjectStorage

internal class AuthTokenMock: AuthTokenManager{
    
    //return a mock token
    override func refreshAuthToken(_ completionHandler: @escaping (ObjectStorageError?, String?) -> Void) {
        self.authToken = "mockToken"
        completionHandler(nil, self.authToken)
    }
    
}
