//
//  HttpManager.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

internal protocol Manager{
    
    /**
     Send a GET request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func get(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a PUT request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter data: The data to send in request body
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a DELETE request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a POST request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter data: The data to send in request body
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a HEAD request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler)
    
    func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager
    
    func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager
}