//
//  RoutePlotResponse
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Plot
import Vapor


/*
 A RoutePlotResponse renders a Vapor.Response with a redirect code
 */
public protocol RoutePlotResponse: RouteResponse {
    func html(_ output: Output) async throws -> Plot.HTML
}

public extension RoutePlotResponse {
    func encodeOutputToVaporResponse(_ output: Output, with vaporRequest: Vapor.Request) async throws -> Vapor.Response {
        let html = try await html(output)

        let htmlString: String
        switch vaporRequest.application.environment {
        case .development:
            htmlString = html.render(indentedBy: .spaces(4))
        default:
            htmlString = html.render()
        }

        var mutableHeaders = HTTPHeaders()
        mutableHeaders.replaceOrAdd(name: .contentType, value: "text/html")

        return .init(status: .ok, headers: mutableHeaders, body: .init(stringLiteral: htmlString))
    }
}
