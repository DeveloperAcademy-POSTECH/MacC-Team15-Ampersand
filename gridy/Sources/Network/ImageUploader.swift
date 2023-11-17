//
//  ImageUploader.swift
//  gridy
//
//  Created by 제나 on 11/4/23.
//

import AppKit
import FirebaseStorage

struct ImageUploader {
    static func uploadImage(uid: String, image: NSImage) async -> String {
        var imageURL = ""
        if let imageData = image.tiffRepresentation(using: .jpeg, factor: 0.5) {
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "\(uid)/\(filename)")
            
            ref.putData(imageData, metadata: nil) { _, _ in
                ref.downloadURL { url, _ in
                    if let url = url?.absoluteString {
                        imageURL = url
                    }
                }
            }
        }
        return imageURL
    }
}
