//
//  RouteHTTPInput
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Vapor


public protocol RouteHTTPRequest: RouteRequest {
    typealias Parameters = Vapor.Parameters
    associatedtype Query: Decodable = RouteHTTPRequestEmptyQuery
    associatedtype Content: Decodable = RouteHTTPRequestEmptyContent

    func decodeToInput(_ parameters: Parameters, query: Query, content: Content) async throws -> Input
}

private extension RouteHTTPRequest where Query: Decodable {
    func decodeVaporRequestToQuery(_ vaporRequest: Vapor.Request) throws -> Query {
        if let Q = Query.self as? Validatable.Type {
            try Q.validate(query: vaporRequest)
        }
        
        return try vaporRequest.query.decode(Query.self)
    }
}

private extension RouteHTTPRequest where Content: Decodable {
    func decodeVaporRequestToContent(_ vaporRequest: Vapor.Request) throws -> Content {
        if let C = Content.self as? Validatable.Type {
            try C.validate(content: vaporRequest)
        }

        return try vaporRequest.content.decode(Content.self)
    }
}


public struct RouteHTTPRequestEmptyQuery: Decodable {}
public struct RouteHTTPRequestEmptyContent: Decodable {}

public extension RouteHTTPRequest {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters
        let query = try decodeVaporRequestToQuery(vaporRequest)
        let content = try decodeVaporRequestToContent(vaporRequest)

        return try await decodeToInput(parameters, query: query, content: content)
    }
}

public extension RouteHTTPRequest where Query == RouteHTTPRequestEmptyQuery {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters
        let content = try decodeVaporRequestToContent(vaporRequest)

        return try await decodeToInput(parameters, query: .init(), content: content)
    }
}

public extension RouteHTTPRequest where Content == RouteHTTPRequestEmptyContent {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters
        let query = try decodeVaporRequestToQuery(vaporRequest)

        return try await decodeToInput(parameters, query: query, content: .init())
    }
}

public extension RouteHTTPRequest where Query == RouteHTTPRequestEmptyQuery, Content == RouteHTTPRequestEmptyContent {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters

        return try await decodeToInput(parameters, query: .init(), content: .init())
    }
}
