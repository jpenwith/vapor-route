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
public protocol RouteViewResponse: RouteResponse {
    associatedtype ViewContext: RouteViewResponseViewContext = RouteViewResponseEmptyViewContext<Self.Output> where ViewContext.Output == Self.Output

    var viewName: String { get }
}

private extension RouteViewResponse {
    func renderViewWithOutput(_ output: Output, vaporRequest: Vapor.Request) async throws -> Vapor.View {
        try await vaporRequest.view.render(
            viewName,
            ViewContext(output: output)
        )
    }
}

public extension RouteViewResponse {
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

public struct RouteViewResponseEmptyViewContext<Output>: RouteViewResponseViewContext {
    public init(output: Output) {}
}

public protocol RouteViewResponseViewContext: Encodable {
    associatedtype Output

    init(output: Output)
}
