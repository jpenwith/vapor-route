//
//  Route
//
//
//  Created by me on 17/03/2024.
//

import Foundation
import Vapor
import VaporUtils


public protocol Route {
    var method: Vapor.HTTPMethod { get }
    var path: String { get }

    associatedtype Request:  AsyncRequestDecodable   = EmptyRequest
    associatedtype Response: AsyncResponseEncodable  = Vapor.Response
}


public extension RoutesBuilder {
    @discardableResult
    func register<R>(route: R, body: HTTPBodyStreamStrategy = .collect, use closure: @Sendable @escaping (R.Request, Vapor.Request) async throws -> R.Response) -> Vapor.Route where R: Route {
        self.on(route.method, route.path.pathComponents, body: body, use: closure)
    }
}


public protocol SelfHandleRoute: Route {
    @Sendable
    func handle(_ request: Request, vaporRequest: Vapor.Request) async throws -> Response
}


public extension RoutesBuilder {
    @discardableResult
    func register<R>(route: R) -> Vapor.Route where R: SelfHandleRoute {
        self.on(route.method, route.path.pathComponents, use: route.handle)
    }
}
