//
//  FirestoreService.swift
//  gridy
//
//  Created by 제나 on 10/30/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

enum CollectionName: String {
    case plans = "Plans"
    case deletePlans = "DeletedPlans"
    case planTypes = "PlanTypes"
    case deletePlanTypes = "DeletedPlanTypes"
    
    case feedback = "Feedback"
    case notice = "Notice"
}

struct FirestoreService {
    // MARK: - methods for convenience
    /// Currently authenticated user
    static var uid: String {
        get throws {
            guard let uid = Auth.auth().currentUser?.uid else { throw APIError.noAuthenticatedUser }
            return uid
        }
    }
    
    /// Base firestore path for API Service
    static var basePath: DocumentReference {
        get throws {
            let firestore = Firestore.firestore().collection("ProjectCollection")
            return firestore.document(try uid)
        }
    }
    
    static func independentPath(_ collection: CollectionName) -> CollectionReference {
        return Firestore.firestore().collection(collection.rawValue)
    }
    
    static var projectCollectionPath: CollectionReference {
        get throws {
            return try basePath.collection("Projects")
        }
    }

    static var deletedProjectCollectionPath: CollectionReference {
        get throws {
            return try basePath.collection("DeletedProjects")
        }
    }
    
    static func collectionPath(
        _ projectID: String,
        _ collectionName: String
    ) throws -> CollectionReference {
        return try basePath.collection("Projects").document(projectID).collection(collectionName)
    }
    
    static func getDocument(
        _ projectID: String,
        _ collectionName: CollectionName,
        _ documentID: String,
        _ decodeTo: Decodable.Type
    ) async throws -> Decodable {
        return try await collectionPath(projectID, collectionName.rawValue)
            .document(documentID)
            .getDocument(as: decodeTo.self)
    }
    
    static func getDocuments(
        _ projectID: String,
        _ collectionName: CollectionName,
        _ decodeTo: Decodable.Type
    ) async throws -> [Decodable] {
        return try await collectionPath(projectID, collectionName.rawValue)
            .getDocuments()
            .documents
            .map { try $0.data(as: decodeTo.self) }
    }
    
    static func updateDocumentData(
        _ projectID: String,
        _ collection: CollectionName,
        _ documentID: String,
        _ data: [String: Any]
    ) async throws {
        try await collectionPath(projectID, collection.rawValue)
            .document(documentID)
            .updateData(data)
    }
    
    static func deleteDocument(
        _ projectID: String,
        _ collection: CollectionName,
        _ documentID: String
    ) async throws {
        try await collectionPath(projectID, collection.rawValue)
            .document(documentID)
            .delete()
    }
    
    static func getNewDocumentID(
        _ projectID: String,
        _ collection: CollectionName
    ) throws -> String {
        return try collectionPath(projectID, collection.rawValue).document().documentID
    }
    
    static func setDocumentData(
        _ projectID: String,
        _ collection: CollectionName,
        _ documentID: String,
        _ data: [String: Any]
    ) async throws {
        try await collectionPath(projectID, collection.rawValue)
            .document(documentID)
            .setData(data)
    }
}
