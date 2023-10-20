//
//  APIError.swift
//  gridy
//
//  Created by 제나 on 10/9/23.
//

import Foundation

enum APIError: Error {
    case noResponseResult
    case noAuthenticatedUser
    case errorOccurred
}
