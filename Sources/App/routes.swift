import Vapor

func routes(_ app: Application) throws {
    let userAPI = UserAPI()

    app.handle(IndexUsersRoute()) { _, _ in
        await userAPI.index()
    }

    app.handle(CreateUserRoute()) { input, _ in
        let user = await userAPI.create(name: input.userName, email: input.userEmail, password: input.userPassword)

        return user
    }

    app.handle(ReadUserRoute()) { input, _ in
        guard let user = await userAPI.read(input.userID) else {
            throw Abort(.notFound)
        }

        return user
    }
    
    app.handle(UpdateUserRoute()) { input, _ in
        guard let user = await userAPI.update(input.userID, name: input.userName, email: input.userEmail, password: input.userPassword) else {
            throw Abort(.notFound)
        }

        return user
    }
    
    app.handle(DeleteUserRoute()) { input, _ in
        guard let user = await userAPI.delete(input.userID) else {
            throw Abort(.notFound)
        }

        return user
    }
}

struct User: Vapor.Content {
    let id: UUID
    var name: String
    var email: String
    var password: String
}

actor UserAPI {
    var users: [User] = [
        .init(id: .init(uuidString: "C03AB8DC-2F09-415F-AF30-7E863292C064")!, name: "Alice", email: "alice@example.com", password: "secret")
    ]

    func index() -> [User] {
        users
    }
    
    func create(name: String, email: String, password: String) -> User {
        let user = User(id: .init(), name: name, email: email, password: password)

        users.append(user)

        return user
    }
    
    func read(_ id: UUID) -> User? {
        guard let userIndex = users.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        return users[userIndex]
    }

    func update(_ id: UUID, name: String? = nil, email: String? = nil, password: String? = nil) -> User? {
        guard let userIndex = users.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        users[userIndex].name = name ?? users[userIndex].name
        users[userIndex].email = email ?? users[userIndex].email
        users[userIndex].password = password ?? users[userIndex].password

        return users[userIndex]
    }
    
    func delete(_ id: UUID) -> User? {
        guard let userIndex = users.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        return users.remove(at: userIndex)
    }
}


struct IndexUsersRoute: Route  {
    let path = "users"

    
}

extension IndexUsersRoute {
    struct Response: RouteViewResponse {
        typealias Output = [User]

        var templateName: String { "users/index.leaf" }
        
        struct ViewContext: Encodable {
            let users: [User]
        }
        
        func createViewContext(_ output: [User]) -> ViewContext? {
            .init(users: output)
        }
    }
}


struct CreateUserRoute: Route  {
    let method: HTTPMethod = .POST
    let path = "users"
    
    struct Request: RouteHTTPRequest {
        struct Input {
            let userName: String
            let userEmail: String
            let userPassword: String
        }
        
        struct Content: Decodable {
            let name: String
            let email: String
            let password: String
        }
        
        func decodeToInput(_ parameters: Parameters, query: EmptyQuery, content: Content) async throws -> Input {
            .init(
                userName: content.name,
                userEmail: content.email,
                userPassword: content.password
            )
        }
    }
    
    struct Response: RouteViewResponse {
        typealias Output = User

        var templateName: String { "users/read.leaf" }

        struct ViewContext: Encodable {
            let user: User
        }

        func createViewContext(_ output: User) -> ViewContext? {
            .init(user: output)
        }
    }
}



struct ReadUserRoute: Route  {
    let path = "users/:userID"

    struct Request: RouteHTTPRequest {
        struct Input {
            let userID: UUID
        }

        func decodeToInput(_ parameters: Parameters, query: EmptyQuery, content: EmptyContent) async throws -> Input {
            .init(userID: try parameters.require("userID"))
        }
    }
    
    struct Response: RouteViewResponse {
        typealias Output = User

        var templateName: String { "users/read.leaf" }

        struct ViewContext: Encodable {
            let user: User
        }

        func createViewContext(_ output: User) -> ViewContext? {
            .init(user: output)
        }
    }
}



struct UpdateUserRoute: Route  {
    let method: HTTPMethod = .PATCH
    let path = "users/:userID"

    struct Request: RouteHTTPRequest {
        struct Input {
            let userID: UUID
            let userName: String
            let userEmail: String
            let userPassword: String
        }
        
        struct Content: Decodable {
            let name: String
            let email: String
            let password: String
        }

        func decodeToInput(_ parameters: Parameters, query: EmptyQuery, content: Content) async throws -> Input {
            .init(
                userID: try parameters.require("userID"),
                userName: content.name,
                userEmail: content.email,
                userPassword: content.password
            )
        }
    }

    struct Response: RouteViewResponse {
        typealias Output = User
        
        var templateName: String { "users/read.leaf" }

        struct ViewContext: Encodable {
            let user: User
        }

        func createViewContext(_ output: User) -> ViewContext? {
            .init(user: output)
        }
    }
}



struct DeleteUserRoute: Route  {
    let method: HTTPMethod = .DELETE
    let path = "users/:userID"

    struct Request: RouteHTTPRequest {
        struct Input {
            let userID: UUID
        }
        
        func decodeToInput(_ parameters: Parameters, query: EmptyQuery, content: EmptyContent) async throws -> Input {
            .init(userID: try parameters.require("userID"))
        }

    }

    struct Response: RouteViewResponse {
        typealias Output = User
        
        var templateName: String { "users/read.leaf" }

        struct ViewContext: Encodable {
            let user: Output
        }

        func createViewContext(_ output: User) -> ViewContext? {
            .init(user: output)
        }
    }
}
