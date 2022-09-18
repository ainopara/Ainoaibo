//
//  Alamofire+ResponseDecodable.swift
//  Ainoaibo
//
//  Created by Zheng Li on 2018/6/23.
//  Copyright © 2018 ain. All rights reserved.
//

import Alamofire

public typealias ErrorInResponseHandler = (Data) -> Error?

public enum AllowNullResponse<T> {
    case no
    case allow(defaultValue: T)
}

public class CodableResponseSerializer<T: Decodable>: ResponseSerializer {

    let handleErrorInResponse: ErrorInResponseHandler?
    let allowNullResponse: AllowNullResponse<T>

    init(handleErrorInResponse: ErrorInResponseHandler?, allowNullResponse: AllowNullResponse<T>) {
        self.handleErrorInResponse = handleErrorInResponse
        self.allowNullResponse = allowNullResponse
    }

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        guard error == nil else { throw error! }

        let emptyDataStatusCodes: Set<Int> = [204, 205]

        if let response = response, emptyDataStatusCodes.contains(response.statusCode) {
            // We are expecting json data returned from this request.
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }

        guard let validData = data, validData.count > 0 else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }

        if case let .allow(defaultValue) = allowNullResponse, validData == "null".data(using: .utf8) {
            return defaultValue
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            if let errorInResponseHandler = handleErrorInResponse, let error = errorInResponseHandler(validData) {
                throw error
            }

            let json = try decoder.decode(T.self, from: validData)
            return json
        } catch {
            LogError("Failed to serialize data as \(String(describing: T.self)): \(String(decoding: validData, as: UTF8.self))", category: .network)
            throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        }
    }
}

extension Alamofire.DataRequest {

    @discardableResult
    public func responseDecodable<T: Decodable>(
        handleErrorInResponse: ErrorInResponseHandler? = nil,
        allowNullResponse: AllowNullResponse<T> = .no,
        queue: DispatchQueue = .main,
        completionHandler: @escaping (AFDataResponse<T>) -> Void
    ) -> Self {
        return response(
            queue: queue,
            responseSerializer: CodableResponseSerializer(
                handleErrorInResponse: handleErrorInResponse,
                allowNullResponse: allowNullResponse
            ),
            completionHandler: { (response: AFDataResponse<T>) in
                let url = response.request?.url ?? URL(fileURLWithPath: "nil")
                switch response.result {
                case .success:
                    LogDebug("\(url)" + "\n", category: .network)
                case let .failure(error):
                    LogDebug("\(url)" + "\n" + String(dumping: error), category: .network)
                }

                completionHandler(response)
            }
        )
    }
}
