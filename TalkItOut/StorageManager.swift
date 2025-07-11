import Foundation
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()
    
    private init() {}
    
    /// Uploads a file to Firebase Storage and returns the download URL on success.
    /// - Parameters:
    ///   - localFile: The local file URL to upload.
    ///   - path: The path in Firebase Storage (e.g., "user_videos/filename.mp4").
    ///   - completion: Completion handler with Result<URL, Error>.
    func uploadFile(localFile: URL, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType(for: localFile)
        
        storageRef.putFile(from: localFile, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(NSError(domain: "StorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error getting download URL"])) )
                }
            }
        }
    }
    
    /// Helper to determine content type from file extension
    private func contentType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "m4a": return "audio/mp4"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        default: return "application/octet-stream"
        }
    }
}
