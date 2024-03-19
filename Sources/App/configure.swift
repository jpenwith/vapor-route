import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.views.use(.leaf)

    try routes(app)
}
