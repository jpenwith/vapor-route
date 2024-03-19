//
//  RouteHTTPInput
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Vapor


protocol RouteHTTPRequest: RouteRequest {
    typealias Parameters = Vapor.Parameters
    associatedtype Query: Decodable = EmptyQuery
    associatedtype Content: Decodable = EmptyContent

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


struct EmptyQuery: Decodable {}
struct EmptyContent: Decodable {}

extension RouteHTTPRequest {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters
        let query = try decodeVaporRequestToQuery(vaporRequest)
        let content = try decodeVaporRequestToContent(vaporRequest)

        return try await decodeToInput(parameters, query: query, content: content)
    }
}

extension RouteHTTPRequest where Query == EmptyQuery {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters
        let content = try decodeVaporRequestToContent(vaporRequest)

        return try await decodeToInput(parameters, query: .init(), content: content)
    }
}

extension RouteHTTPRequest where Content == EmptyContent {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters
        let query = try decodeVaporRequestToQuery(vaporRequest)

        return try await decodeToInput(parameters, query: query, content: .init())
    }
}

extension RouteHTTPRequest where Query == EmptyQuery, Content == EmptyContent {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        let parameters = vaporRequest.parameters

        return try await decodeToInput(parameters, query: .init(), content: .init())
    }
}



//extension RoutesBuilder {
//    func handle<R>(_ route: R, body: HTTPBodyStreamStrategy = .collect, use handler: @escaping R.Handler) where R: HTTPRoute, R.Content == EmptyContent {
//        self.on(route.method, route.path.pathComponents, body: body, use: { vaporRequest in
//            //Decode the Vapor.Request to a Route.Input
//            let routeInput = try await route.decodeVaporRequestToInput(vaporRequest)
//
//            //Call the handler
//            let routeOutput = try await handler(routeInput, vaporRequest)
//
//            //Encode the Route.Output to a Vapor.Response
//            return try await route.encodeOutputToVaporResponse(routeOutput, with: vaporRequest)
//        })
//    }
//}
