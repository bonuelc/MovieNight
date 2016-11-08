//
//  APIClient.swift
//  MovieNight
//
//  Created by Pasan Premaratne on 5/4/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

public let TRENetworkingErrorDomain = "com.treehouse.MovieNight.NetworkingError"

public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20
public let MissingJSONAndErrorError: Int = 30

typealias JSON = [String: AnyObject]
typealias JSONCompletion = (JSON?, NSHTTPURLResponse?, NSError?) -> Void
typealias JSONTask = NSURLSessionDataTask

protocol JSONDecodable {
    init?(JSON: [String : AnyObject])
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }
}

extension Endpoint {
    var queryComponents: [NSURLQueryItem] {
        var components = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.append(queryItem)
        }
        
        return components
    }
    
    var request: NSURLRequest {
        let components = NSURLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryComponents
        
        let url = components.URL!
        return NSURLRequest(URL: url)
    }
}

enum APIResult<T> {
    case Success(T)
    case Failure(ErrorType)
}

protocol APIClient {
    var configuration: NSURLSessionConfiguration { get }
    var session: NSURLSession { get }
    
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void)
    func fetch<T: JSONDecodable>(endpoint: Endpoint, parse: JSON -> T?, completion: APIResult<T> -> Void)
    func fetch<T: JSONDecodable>(endpoint: Endpoint, parse: JSON -> [T]?, completion: APIResult<[T]> -> Void)
 }

extension APIClient {
    
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONCompletion) -> JSONTask {
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard let HTTPResponse = response as? NSHTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: TRENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            guard let data = data else {
                if let error = error {
                    completion(nil, HTTPResponse, error)
                }
                return
            }
            
            switch HTTPResponse.statusCode {
            case 200:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String : AnyObject]
                    completion(json, HTTPResponse, nil)
                } catch let error as NSError {
                    completion(nil, HTTPResponse, error)
                }
            default:
                print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled")
            }
        }
        
        return task
    }
    
    func fetch<T>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void) {
        
        let task = JSONTaskWithRequest(request) { json, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                guard let json = json else {
                    if let error = error {
                        completion(.Failure(error))
                    } else {
                        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("json and error are both set to nil", comment: "")]
                        let error = NSError(domain: TRENetworkingErrorDomain, code: MissingJSONAndErrorError, userInfo: userInfo)
                        
                        completion(.Failure(error))
                    }
                    return
                }
                
                if let resource = parse(json) {
                    completion(.Success(resource))
                } else {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.Failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func fetch<T: JSONDecodable>(endpoint: Endpoint, parse: JSON -> T?, completion: APIResult<T> -> Void) {
        fetch(endpoint.request, parse: parse, completion: completion)
    }
    
    func fetch<T: JSONDecodable>(endpoint: Endpoint, parse: JSON -> [T]?, completion: APIResult<[T]> -> Void) {
        
        let request = endpoint.request
        
        let task = JSONTaskWithRequest(request) { json, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                guard let json = json else {
                    if let error = error {
                        completion(.Failure(error))
                    } else {
                        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("json and error are both set to nil", comment: "")]
                        let error = NSError(domain: TRENetworkingErrorDomain, code: MissingJSONAndErrorError, userInfo: userInfo)
                        
                        completion(.Failure(error))
                    }
                    return
                }
                
                if let resource = parse(json) {
                    completion(.Success(resource))
                } else {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.Failure(error))
                }
            }
        }
        
        task.resume()
    }
}

