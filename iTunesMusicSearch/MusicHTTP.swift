//
//  MusicHTTP.swift
//  iTunesMusicSearch
//
//  Created by Rey Felipe on 6/29/19.
//  Copyright © 2019 Rey Felipe. All rights reserved.
//
//  based on: https://gist.github.com/pedromancheno/7092a9f706a1df71ce2bf64fbd2884a9
//

import Foundation

enum Result<T> {
    case success(T?)
    case failure(Error)
}

enum MusicHTTPError: Error {
    case noResponse
    case unsuccesfulStatusCode(Int)
}

typealias MusicHTTPCompletion = ((Result<[String:Any]>) -> Void)

struct MusicHTTP {
    private static var successCodes: Range<Int> = 200..<299
    
    static func execute(request: URL, completion: @escaping MusicHTTPCompletion) {
        
        let session = URLSession.shared
        var task: URLSessionDataTask?
        
        task = session.dataTask(with: request) { (data: Data?, response:URLResponse?, error:Error?) in
            
            guard let error = error else {
                self.evaluate(data: data, response: response, completion: completion)
                return
            }
            
            completion(.failure(error))
        }
        
        task?.resume()
    }
    
    fileprivate static func evaluate(data: Data?, response: URLResponse?, completion: MusicHTTPCompletion) {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(MusicHTTPError.noResponse))
            return
        }
        
        validateStatusCodes(data: data, httpResponse: httpResponse, completion: completion)
        
    }
    
    fileprivate static func validateStatusCodes(data: Data?, httpResponse: HTTPURLResponse, completion: MusicHTTPCompletion) {
        
        guard successCodes.contains(httpResponse.statusCode) else {
            completion(.failure(MusicHTTPError.unsuccesfulStatusCode(httpResponse.statusCode)))
            return
        }
        
        makeJSON(data: data, completion: completion)
    }
    
    fileprivate static func makeJSON(data: Data?, completion: MusicHTTPCompletion) {
        guard let data = data else {
            completion(.success(nil))
            return
        }
        
        let json = dataToJSON(data: data)
        completion(.success(json))
    }
    
    fileprivate static func dataToJSON(data: Data) -> [String:Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
        } catch let jsonError {
            debugPrint(jsonError)
        }
        return nil
    }
}
