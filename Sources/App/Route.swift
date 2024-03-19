//
//  Route
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Vapor


/*
 A Route defines an Input and how to decode it from a Vapor.Request, and an Output and how to encode it to a Vapor.Response
 
 The Route does the work of decoding the Vapor.Request into an Input, and encoding the Output into a Vapor.Response. This includes transforming potentially
 different kinds of Vapor.Requests (e.g. JSON, multipart-form, etc) into the same Input, and transforming the same Output into potentially different kinds
 of Vapor.Response (e.g. HTML, json, etc)
 */
protocol Route {
    var method: Vapor.HTTPMethod { get }
    var path: String { get }

    associatedtype Request: RouteRequest = EmptyRequest
//    associatedtype Input = EmptyInput
//    associatedtype Output = EmptyOutput
    associatedtype Response: RouteResponse

//    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input
//    func encodeOutputToVaporResponse(_ output: Output, with vaporRequest: Vapor.Request) async throws -> Vapor.Response

    typealias Handler = @Sendable (_ input: Request.Input, _ vaporRequest: Vapor.Request) async throws -> Response.Output
}

extension Route {
    var request: Request { .init() }
}

extension Route {
    var response: Response { .init() }
}


//Default to GET requests
extension Route {
    var method: Vapor.HTTPMethod { .GET }
}

//Default to root path
extension Route {
    var path: String { "/" }
}



protocol RouteRequest {
    associatedtype Input = EmptyInput
    
    init()
    
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input
}

//Make Input: AsyncRequestDecodable (e.g. conform to Vapor.Content) to skip the decoding step
extension RouteRequest where Input: AsyncRequestDecodable {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        try await Input.decodeRequest(vaporRequest)
    }
}

//Leave Input as EmptyInput (the default) to skip decoding altogether. Useful for returning static content
extension RouteRequest where Input == EmptyInput {
    func decodeVaporRequestToInput(_ vaporRequest: Vapor.Request) async throws -> Input {
        .init()
    }
}

struct EmptyRequest: RouteRequest {
    typealias Input = EmptyInput
}





protocol RouteResponse {
    associatedtype Output = EmptyOutput
    
    init()
    
    func encodeOutputToVaporResponse(_ output: Output, with vaporRequest: Vapor.Request) async throws -> Vapor.Response
}

//Make Output: AsyncRequestDecodable (e.g. conform to Vapor.Content) to skip the encoding step
extension RouteResponse where Output: AsyncResponseEncodable {
    func encodeOutputToVaporResponse(_ output: Output, with vaporRequest: Vapor.Request) async throws -> Vapor.Response {
        try await output.encodeResponse(for: vaporRequest)
    }
}



struct EmptyInput {}
struct EmptyOutput {}




//How to register a route
extension RoutesBuilder {
    func handle<R>(_ route: R, body: HTTPBodyStreamStrategy = .collect, use handler: @escaping R.Handler) where R: Route {
        self.on(route.method, route.path.pathComponents, body: body, use: { vaporRequest in
            //Decode the Vapor.Request to a Route.Input
            let routeInput = try await route.request.decodeVaporRequestToInput(vaporRequest)

            //Call the handler
            let routeOutput = try await handler(routeInput, vaporRequest)

            //Encode the Route.Output to a Vapor.Response
            return try await route.response.encodeOutputToVaporResponse(routeOutput, with: vaporRequest)
        })
    }
}
