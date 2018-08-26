//
//  AuthNetworkManager.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/23.
//  Copyright © 2018 ain. All rights reserved.
//

import Alamofire
import SafariServices
#if swift(>=4.1.50)
import AuthenticationServices
#endif

public enum AuthError: Error {
    case configurationError(message: String)
    case retain
    case serverError(message: String)
    case missingCallback
    case missingCode(url: URL)
    case presentationError
    case missingToken
    case cancelled
}

// MARK: -

public final class AuthNetworkManager: NSObject, SFSafariViewControllerDelegate {
    public let clientID: String
    public let clientSecret: String
    public let redirectURI: String
    public let authorizeURL: String
    public let accessTokenURL: String

    public var retrier: RequestRetrier? {
        get { return sessionManager.retrier }
        set { sessionManager.retrier = newValue }
    }

    private let sessionManager: SessionManager

    private var currentSession: Any?
    private weak var safariViewController: SFSafariViewController?
    private var savedCompletionHandler: ((Result<String>) -> Void)?

    public init(clientID: String, clientSecret: String, authorizeURL: String, redirectURI: String, accessTokenURL: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.authorizeURL = authorizeURL
        self.accessTokenURL = accessTokenURL

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        self.sessionManager = SessionManager(configuration: configuration)

        super.init()
    }

    public func authorizeCode(state: String, completion: @escaping (Result<String>) -> Void) {
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

//        if #available(iOS 12.0, *) {
//            let session = ASWebAuthenticationSession(url: targetURL, callbackURLScheme: redirectURI) { (callbackURL, error) in
//                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
//                    completion(.failure(AuthError.cancelled))
//                    return
//                }
//
//                guard let callbackURL = callbackURL else {
//                    completion(.failure(AuthError.missingCallback))
//                    return
//                }
//
//                guard
//                    let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
//                    let code = queryItems.first(where: { $0.name == "code" })?.value
//                else {
//                    completion(.failure(AuthError.missingCode(url: callbackURL)))
//                    return
//                }
//
//                completion(.success(code))
//            }
//
//            currentSession = session
//
//            session.start()
//        } else
        if #available(iOS 11.0, *) {
            let session = SFAuthenticationSession(url: targetURL, callbackURLScheme: redirectURI) { (callbackURL, error) in
                if let error = error as? SFAuthenticationError, error.code == .canceledLogin {
                    completion(.failure(AuthError.cancelled))
                    return
                }

                guard let callbackURL = callbackURL else {
                    completion(.failure(AuthError.missingCallback))
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

            session.start()
        } else {
            // Fallback on earlier versions
            let safariViewController = SFSafariViewController(url: targetURL)
            safariViewController.delegate = self
            self.safariViewController = safariViewController
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                completion(.failure(AuthError.presentationError))
                return
            }

            savedCompletionHandler = completion

            rootViewController.present(safariViewController, animated: true, completion: nil)
        }
    }

//    @available(iOS, obsoleted: 11.0, message: "This method should only be used in iOS 10")
    public func continueAuthorizeCode(callbackURL: URL) {
        guard let completion = savedCompletionHandler else {
            LogError("Get callback with url: \(callbackURL) but can not found saved completion handler.")
            return
        }

        guard
            let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
            let code = queryItems.first(where: { $0.name == "code" })?.value
        else {
            completion(.failure(AuthError.missingCode(url: callbackURL)))
            return
        }

        guard let safariViewController = self.safariViewController else {
            completion(.failure(AuthError.presentationError))
            return
        }

        safariViewController.dismiss(animated: true) {
            completion(.success(code))

            self.savedCompletionHandler = nil
        }
    }

//    @available(iOS, obsoleted: 11.0, message: "This method should only be used in iOS 10")
    private func cancelAuthorizeCode() {
        guard let completion = savedCompletionHandler else {
            LogError("Cancel called but can not found saved completion handler.")
            return
        }

        completion(.failure(AuthError.cancelled))

        savedCompletionHandler = nil
    }


    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        cancelAuthorizeCode()
    }

    @discardableResult
    public func accessToken<AccessToken: Decodable>(
        code: String,
        state: String,
        completionBlock: @escaping (DataResponse<AccessToken>) -> Void
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
        completionBlock: @escaping (DataResponse<AccessToken>) -> Void
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
