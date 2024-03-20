//
//  RouteRedirectResponse
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Vapor


/*
 A RouteRedirectResponse renders a Vapor.Response with a redirect code
 */
public protocol RouteRedirectResponse: RouteResponse {
    var redirectLocation: String { get }
    var redirectType: Vapor.Redirect { get }
}

public extension RouteRedirectResponse {
    var redirectType: Vapor.Redirect { .normal }
}

public extension RouteRedirectResponse {
    func encodeOutputToVaporResponse(_ output: Output, with vaporRequest: Vapor.Request) async throws -> Vapor.Response {
        return vaporRequest.redirect(to: redirectLocation, redirectType: redirectType)
    }
}
