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
    
    override func refreshAuthToken(completionHandler:(error: ObjectStorageError?, authToken: String?) -> Void) {
        self.authToken = "mockToken"
        completionHandler(error: nil, authToken: self.authToken)
    }
    
}