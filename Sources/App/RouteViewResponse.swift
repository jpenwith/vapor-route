//
//  RouteViewResponse
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Vapor


/*
 A RouteViewResponse renders a Vapor.View from a template and supplies a Context if needed
 */
protocol RouteViewResponse: RouteResponse {
    associatedtype ViewContext: Encodable = Output

    var templateName: String { get }
    func createViewContext(_ output: Output) -> ViewContext?
}

//Default to no context
extension RouteViewResponse  {
    func createViewContext(_ output: Output) -> ViewContext? {
        nil
    }
}

//Or define Context as Route.Output to just provide that
extension RouteViewResponse where ViewContext == Output  {
    func createViewContext(_ output: Output) -> ViewContext? {
        output
    }
}

extension RouteViewResponse {
    func renderViewWithOutput(_ output: Output, vaporRequest: Vapor.Request) async throws -> Vapor.View {
        try await vaporRequest.view.render(
            templateName,
            createViewContext(output)
        )
    }
}

extension RouteViewResponse {
    func encodeOutputToVaporResponse(_ output: Output, with vaporRequest: Vapor.Request) async throws -> Vapor.Response {
        try await renderViewWithOutput(
            output,
            vaporRequest: vaporRequest
        )
        .encodeResponse(
            for: vaporRequest
        )
    }
}

struct EmptyViewContext: Encodable {}
