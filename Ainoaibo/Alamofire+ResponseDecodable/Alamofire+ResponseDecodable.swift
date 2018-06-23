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

extension Alamofire.DataRequest {
    public static func decodableResponseSerializer<T: Decodable>(
        handleErrorInResponse: ErrorInResponseHandler?,
        allowNullResponse: AllowNullResponse<T>
    ) -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }

            let emptyDataStatusCodes: Set<Int> = [204, 205]

            if let response = response, emptyDataStatusCodes.contains(response.statusCode) {
                // We are expecting json data returned from this request.
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }

            guard let validData = data, validData.count > 0 else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
            }

            if case let .allow(defaultValue) = allowNullResponse, validData == "null".data(using: .utf8) {
                return .success(defaultValue)
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970

                if let errorInResponseHandler = handleErrorInResponse, let error = errorInResponseHandler(validData) {
                    return .failure(error)
                }

                let json = try decoder.decode(T.self, from: validData)
                return .success(json)
            } catch {
                LogError("Failed to serialize data as \(String(describing: T.self)): \(String(decoding: validData, as: UTF8.self))", category: .network)
                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
            }
        }
    }

    @discardableResult
    public func responseDecodable<T: Decodable>(
        handleErrorInResponse: ErrorInResponseHandler? = nil,
        allowNullResponse: AllowNullResponse<T> = .no,
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void
    ) -> Self {
        return response(
            queue: queue,
            responseSerializer: DataRequest.decodableResponseSerializer(
                handleErrorInResponse: handleErrorInResponse,
                allowNullResponse: allowNullResponse
            ),
            completionHandler: { (response: DataResponse<T>) in
                switch response.result {
                case .success:
                    LogDebug("\(response.request!.url!)" + "\n" + "\(response.timeline)", category: .network)
                case let .failure(error):
                    LogDebug("\(response.request!.url!)" + "\n" + "\(response.timeline)" + "\n" + String(dumping: error), category: .network)
                }

                completionHandler(response)
            }
        )
    }
}
