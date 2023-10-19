//
//  DependencyValues+Extension.swift
//  gridy
//
//  Created by 제나 on 2023/10/01.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
    
    private enum APIClientKey: DependencyKey {
        static let liveValue = APIClient.liveValue
        static let testValue = APIClient.testValue
        static let previewValue = APIClient.mockValue
    }
    
    var apiService: APIService {
        get { self[APIServiceKey.self] }
        set { self[APIServiceKey.self] = newValue }
    }
    
    private enum APIServiceKey: DependencyKey {
        static let liveValue = APIService.liveValue
//        static let testValue = APIService.testValue
//        static let previewValue = APIService.mockValue
    }
}
