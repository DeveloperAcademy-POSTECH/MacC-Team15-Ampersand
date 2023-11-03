//
//  ImageUploader.swift
//  gridy
//
//  Created by 제나 on 11/4/23.
//

import AppKit
import FirebaseStorage

struct ImageUploader {
    static func uploadImage(uid: String, image: NSImage, completion: @escaping(String) -> Void) {
        if let imageData = image.tiffRepresentation(using: .jpeg, factor: 0.5) {
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "\(uid)/\(filename)")
            
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error { return }
                
                ref.downloadURL { url, _ in
                    guard let imageUrl = url?.absoluteString else { return }
                    completion(imageUrl)
                }
            }
        }
    }
}
