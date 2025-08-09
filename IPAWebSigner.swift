import Foundation

class IPAWebSigner {
    let apiBaseUrl: String
    
    init(apiBaseUrl: String) {
        self.apiBaseUrl = apiBaseUrl
    }
    
    func signIPA(ipaData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Always use /api/upload endpoint
        guard let url = URL(string: "\(apiBaseUrl)/api/upload") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"app.ipa\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(ipaData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            // Parse JSON and extract "itms_url"
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let itmsURL = json["itms_url"] as? String {
                    completion(.success(itmsURL))
                } else {
                    completion(.failure(NSError(domain: "Error it didnt work", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(NSError(domain: "Error it didnt work", code: 0, userInfo: nil)))
            }
        }
        
        task.resume()
    }
}