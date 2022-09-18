//
//  AuthNetworkManager.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/23.
//  Copyright © 2018 ain. All rights reserved.
//

import Alamofire
import AuthenticationServices

public enum AuthError: Error {
    case configurationError(message: String)
    case retain
    case serverError(message: String)
    case missingCallback(error: Error)
    case missingCode(url: URL)
    case presentationError
    case missingToken
    case cancelled
}

// MARK: -

public final class AuthNetworkManager: NSObject {
    public let clientID: String
    public let clientSecret: String
    public let callbackURLScheme: String
    public let redirectURI: String
    public let authorizeURL: String
    public let accessTokenURL: String

    public let sessionManager: Alamofire.Session

    private var currentSession: ASWebAuthenticationSession?

    public init(
        clientID: String,
        clientSecret: String,
        authorizeURL: String,
        callbackURLScheme: String,
        redirectURI: String,
        accessTokenURL: String
    ) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.callbackURLScheme = callbackURLScheme
        self.redirectURI = redirectURI
        self.authorizeURL = authorizeURL
        self.accessTokenURL = accessTokenURL

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        self.sessionManager = Session(configuration: configuration)

        super.init()
    }

    public func authorizeCode(state: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        let params: Parameters = [
            "client_id": clientID,
            "response_type": "code",
            "redirect_uri": redirectURI,
            "scope": "",
            "state": state
        ]

        guard
            let request = try? URLRequest(url: authorizeURL, method: .get),
            let targetURL = (try? URLEncoding.queryString.encode(request, with: params))?.url
        else {
            completion(.failure(AuthError.configurationError(message: "Failed to generate target URL with base: \(authorizeURL) parameters: \(params)")))
            return
        }

        let session = ASWebAuthenticationSession(url: targetURL, callbackURLScheme: callbackURLScheme) { (callbackURL, error) in
            if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                completion(.failure(AuthError.cancelled))
                return
            }

            guard let callbackURL = callbackURL else {
                completion(.failure(AuthError.missingCallback(error: error!)))
                return
            }

            guard
                let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
                let code = queryItems.first(where: { $0.name == "code" })?.value
            else {
                completion(.failure(AuthError.missingCode(url: callbackURL)))
                return
            }

            completion(.success(code))
        }

        currentSession = session

        session.presentationContextProvider = self
        session.start()
    }

    @discardableResult
    public func accessToken<AccessToken: Decodable>(
        code: String,
        state: String,
        completionBlock: @escaping (AFDataResponse<AccessToken>) -> Void
    ) -> DataRequest {
        let params: Parameters = [
            "grant_type": "authorization_code",
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectURI,
            "state": state
        ]

        let request = self.sessionManager.request(
            accessTokenURL,
            method: .post,
            parameters: params
        )

        return request
            .validate()
            .responseDecodable { (response) in completionBlock(response) }
    }

    @discardableResult
    public func accessToken<AccessToken: Decodable>(
        refreshToken: String,
        completionBlock: @escaping (AFDataResponse<AccessToken>) -> Void
    ) -> DataRequest {
        let params: Parameters = [
            "grant_type": "refresh_token",
            "client_id": clientID,
            "client_secret": clientSecret,
            "refresh_token": refreshToken,
            "redirect_uri": redirectURI
        ]

        let request = self.sessionManager.request(
            accessTokenURL,
            method: .post,
            parameters: params
        )

        return request
            .validate()
            .responseDecodable { (response) in completionBlock(response) }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension AuthNetworkManager: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}
