import Foundation
import Alamofire
import SwiftyJSON

class UserManager {
    
    static let shared = UserManager()
    
    //MARK: - End Points
    let userBaseUrl             = "\(API.baseUrl)user"
    let registerUrl             = "\(API.baseUrl)user/signup"
    let loginUrl                = "\(API.baseUrl)auth/login"
    let fetchProfileUrl         = "\(API.baseUrl)user"
    let fetchRMDTasteUrl        = "\(API.baseUrl)user/recommend/taste"
    let fetchRMDInterestUrl     = "\(API.baseUrl)user/recommend/interest"
    
    let interceptor = Interceptor()
    
    
    func register(
        with model: UserRegisterDTO,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        AF.request(
            registerUrl,
            method: .post,
            parameters: model.parameters,
            encoding: JSONEncoding.default
        ).responseJSON { response in
            guard let statusCode = response.response?.statusCode else { return }
            switch statusCode {
            case 201:
                do {
                    let json = try JSON(data: response.data ?? Data())
                    
                    completion(.success(true))
                } catch {
                    completion(.failure(.internalError))
                }
            default:
                let error = NetworkError.returnError(statusCode: statusCode, responseData: response.data ?? Data())
                print("❗️ \(error.errorDescription)")
                completion(.failure(error))
            }
        }
        
    }
    
    func updateUserInfo(
        with model: UserInfoUpdateDTO,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        AF.request(
            userBaseUrl,
            method: .patch,
            parameters: model.parameters,
            encoding: JSONEncoding.default,
            interceptor: interceptor
        ).responseJSON { response in
            
            switch response.result {
            case .success: completion(.success(true))
            case .failure(_):
                let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                completion(.failure(error))
            }
        }
    }
    
    // 프로필 이미지 업데이트는 formData 로 해야해서 별도로 설정
    func updateUserProfileImage(
        imageData: Data,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(
                imageData,
                withName: "files",
                fileName: "\(UUID().uuidString).jpeg",
                mimeType: "image/jpeg"
            )
        },
                  to: userBaseUrl,
                  method: .patch,
                  interceptor: interceptor
        )
            .validate()
            .responseData { response in
                switch response.result {
                case .success:
                    print("✏️ UserManager - updateUserProfileImage SUCCESS")
                    completion(.success(true))
                case .failure:
                    let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                    completion(.failure(error))
                    print("❗️ UserManager - updateUserProfileImage error: \(error.errorDescription)")
                }
            }
    }
    
    
    // 비번 변경
    func updateUserPassword(
        password: String,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        let parameters: Parameters = ["newPassword": password]
        
        AF.request(
            userBaseUrl,
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default,
            interceptor: interceptor
        ).responseJSON { response in
            
            switch response.result {
            case .success: completion(.success(true))
            case .failure(_):
                let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                completion(.failure(error))
            }
        }
    }
    
    func removeUserProfileImage(completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data("Y".utf8), withName: "force")
        },
                  to: userBaseUrl,
                  method: .patch,
                  interceptor: interceptor
        )
            .validate()
            .responseData { response in
                switch response.result {
                case .success:
                    print("✏️ UserManager - removeUserProfileImage SUCCESS")
                    completion(.success(true))
                case .failure:
                    let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                    completion(.failure(error))
                    print("❗️ UserManager - removeUserProfileImage error: \(error.errorDescription)")
                }
            }
    }
    
    
    func login(
        username: String,
        password: String,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        let parameters = ["user_name": username, "password": password]
        
        AF.request(
            loginUrl,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseJSON { response in
            guard let statusCode = response.response?.statusCode else { return }
            switch statusCode {
            case 200..<300:
                do {
                    let json = try JSON(data: response.data ?? Data())
                    User.shared.accessToken = json["access_token"].stringValue
                    User.shared.userUid = json["user_id"].stringValue
                    User.shared.isLoggedIn = true
                } catch {
                    completion(.failure(.internalError))
                }
                completion(.success(true))
            default:
                let error = NetworkError.returnError(statusCode: statusCode, responseData: response.data ?? Data())
                print("❗️ Login Error: \(error.errorDescription)")
                completion(.failure(error))
            }
            
        }
    }
    
    
    func fetchProfileInfo(completion: @escaping ((Result<UserDisplayModel, NetworkError>) -> Void)) {
        
        let url =  fetchProfileUrl + "?user_id=\(User.shared.userUid)"
        
        AF.request(
            url,
            method: .get,
            interceptor: interceptor
        ).responseJSON { response in
            switch response.result {
            case .success(_):
                print("✏️ UserManager - fetchProfileInfo SUCCESS")
                do {
            
                    let decodedData = try JSONDecoder().decode(UserDisplayModel.self, from: response.data!)
                    
                    User.shared.userUid = decodedData.userUid
                    User.shared.username = decodedData.userName
                    User.shared.displayName = decodedData.displayName
                    User.shared.vegetarianType = decodedData.vegetarianType?.name ?? "-"
                    
                    completion(.success(decodedData))
                } catch {
                    print("❗️ UserManager - fetchProfileInfo Decoding ERROR: \(error)")
                    completion(.failure(.internalError))
                }
            case .failure:
                let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 500, responseData: response.data ?? Data())
                completion(.failure(error))
            }
        }
    }
    
    
    
    func unregisterUser(completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        AF.request(
            userBaseUrl,
            method: .delete,
            interceptor: interceptor
        )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("✏️ UserManager - unregisterUser SUCCESS")
                    completion(.success(true))
                case .failure:
                    print("❗️ UserManager - unregisterUser ERROR")
                    let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                    completion(.failure(error))
                }
            }
    }
    
    func fetchProfileForCommunity(userUID: String,
                                  completion: @escaping ((Result<UserDisplayModel, NetworkError>) -> Void)) {
        
        let parameters: Parameters = ["user_id": userUID]
        
        AF.request(fetchProfileUrl,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.queryString,
                   interceptor: interceptor)
            .responseData { response in
            switch response.result {
            case .success:
                do {
                    let decodedData = try JSONDecoder().decode(UserDisplayModel.self, from: response.data!)
                    completion(.success(decodedData))
                    print("✏️ UserManager - fetchProfileForCommunity SUCCESS")
                } catch {
                    print("❗️ UserManager - fetchProfileForCommunity Decoding ERROR: \(error)")
                    completion(.failure(.internalError))
                }
            case .failure(let error):
                if let jsonData = response.data {
                    print("❗️ UserManager - fetchProfileForCommunity - FAILED REQEUST with server error:\(String(data: jsonData, encoding: .utf8) ?? "")")
                }
                print("❗️ UserManager - fetchProfileForCommunity - FAILED REQEUST with alamofire error: \(error.localizedDescription)")
                guard let responseCode = error.responseCode else {
                    print("❗️ UserManager - fetchProfileForCommunity - Empty responseCode")
                    return
                }
                let customError = NetworkError.returnError(statusCode: responseCode)
                print("❗️ UserManager - fetchProfileForCommunity - FAILED REQEUST with custom error: \(customError.errorDescription)")
                completion(.failure(customError))
            }
        }
    }
    
    func fetchRecommendUser(byTaste: Bool,
                            completion: @escaping ((Result<[UserDisplayModel], NetworkError>) -> Void)) {
        
        let url: String
        if byTaste {
            url = fetchRMDTasteUrl
        } else {
            url = fetchRMDInterestUrl
        }
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.queryString,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
            switch response.result {
            case .success(let value):
                do {
                    let dataJSON = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    let decodedData = try JSONDecoder().decode([UserDisplayModel].self, from: dataJSON)
                    completion(.success(decodedData))
                    print("✏️ \(String(describing: type(of: self))) - \(#function) - fetch SUCCESS")
                } catch {
                    print("✏️ \(String(describing: type(of: self))) - \(#function) - FAILED PROCESS DATA with error: \(error)")
                }
            case .failure(let error):
                if let jsonData = response.data {
                    print("❗️ \(String(describing: type(of: self))) - \(#function) - FAILED REQEUST with server error:\(String(data: jsonData, encoding: .utf8) ?? "")")
                }
                print("❗️ \(String(describing: type(of: self))) - \(#function) - FAILED REQEUST with alamofire error: \(error.localizedDescription)")
                guard let responseCode = error.responseCode else {
                    print("❗️ \(String(describing: type(of: self))) - \(#function) - Empty responseCode")
                    return
                }
                let customError = NetworkError.returnError(statusCode: responseCode)
                print("❗️ \(String(describing: type(of: self))) - \(#function) - FAILED REQEUST with custom error: \(customError.errorDescription)")
                completion(.failure(customError))
            }
        }
    }
}
