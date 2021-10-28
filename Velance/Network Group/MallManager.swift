import Foundation
import Alamofire
import SwiftyJSON

class MallManager {
    
    static let shared = MallManager()
    
    let interceptor = Interceptor()
    
    //MARK: - End Points
    let newMenuUrl              = "\(API.baseUrl)menu"
    let newMallUrl              = "\(API.baseUrl)mall"
    let fetchMallListUrl        = "\(API.baseUrl)mall"
    
    //MARK: - 새로운 메뉴 등록
    func uploadNewMenu(
        with model: NewMenuDTO,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        showProgressBar()
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data(model.createdBy.utf8),withName: "created_by")
            multipartFormData.append(Data(model.mallId.description.utf8),withName: "mall_id")
            multipartFormData.append(Data(model.name.utf8),withName: "name")
            multipartFormData.append(Data(model.price.description.utf8),withName: "price")
            multipartFormData.append(Data(model.caution.utf8),withName: "caution")
            multipartFormData.append(Data(model.isVegan.utf8),withName: "is_vegan")
            
            multipartFormData.append(
                model.files,
                withName: "files",
                fileName: "\(UUID().uuidString).jpeg",
                mimeType: "image/jpeg"
            )
        },
                  to: newMenuUrl,
                  method: .post,
                  interceptor: interceptor
        )
            .validate()
            .responseData { response in
                dismissProgressBar()
                switch response.result {
                case .success:
                    print("✏️ MallManager - uploadNewMenu SUCCESS")
                    completion(.success(true))
                case .failure:
                    let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                    completion(.failure(error))
                    print("❗️ MallManager - uploadNewMenu error: \(error.errorDescription)")
                }
            }
    }
    
    func uploadNewMall(
        with model: NewMallDTO,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        showProgressBar()
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(Data(model.mallId.description.utf8),withName: "mall_id")
            multipartFormData.append(Data(model.createdBy.utf8),withName: "created_by")
            multipartFormData.append(Data(model.placeName.utf8),withName: "place_name")
            multipartFormData.append(Data(model.phone.utf8),withName: "phone")
            multipartFormData.append(Data(model.addressName.utf8),withName: "address_name")
            multipartFormData.append(Data(model.roadAddressName.utf8),withName: "road_address_name")
            multipartFormData.append(Data(model.x.description.utf8),withName: "x")
            multipartFormData.append(Data(model.y.description.utf8),withName: "y")
            multipartFormData.append(Data(model.onlyVegan.utf8),withName: "only_vegan")
            multipartFormData.append(
                model.file,
                withName: "files",
                fileName: "\(UUID().uuidString).jpeg",
                mimeType: "image/jpeg"
            )
        },
                  to: newMallUrl,
                  method: .post,
                  interceptor: interceptor
        )
            .validate()
            .responseData { response in
                dismissProgressBar()
                switch response.result {
                case .success:
                    print("✏️ MallManager - uploadNewMall SUCCESS")
                    completion(.success(true))
                case .failure:
                    let error = NetworkError.returnError(statusCode: response.response?.statusCode ?? 400, responseData: response.data ?? Data())
                    completion(.failure(error))
                    print("❗️ MallManager - uploadNewMall error: \(error.errorDescription)")
                }
            }
        
        
    }
    
    func fetchMallList(with model: MallRequestDTO,
                       completion: @escaping ((Result<[MallResponseDTO], NetworkError>) -> Void)) {
        
        var parameters: Parameters = [:]
        parameters["cursor"] = model.cursor
        parameters["x"] = model.x
        parameters["y"] = model.y
        parameters["radius"] = model.radius
        
        AF.request(fetchMallListUrl,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.queryString,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    do {
                        let dataJSON = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let decodedData = try JSONDecoder().decode([MallResponseDTO].self, from: dataJSON)
                        completion(.success(decodedData))
                        print("✏️ MallManager MANAGER - fetchMallList - fetch SUCCESS")
                    } catch {
                        print("❗️ MallManager MANAGER - fetchMallList - FAILED PROCESS DATA with error: \(error)")
                    }
                case .failure(let error):
                    if let jsonData = response.data {
                        print("❗️ MallManager MANAGER - fetchMallList - FAILED REQEUST with server error:\(String(data: jsonData, encoding: .utf8) ?? "")")
                    }
                    print("❗️ MallManager MANAGER - fetchMallList - FAILED REQEUST with alamofire error: \(error.localizedDescription)")
                    guard let responseCode = error.responseCode else {
                        print("❗️ MallManager MANAGER - fetchMallList - Empty responseCode")
                        return
                    }
                    let customError = NetworkError.returnError(statusCode: responseCode)
                    print("❗️ MallManager MANAGER - fetchMallList - FAILED REQEUST with custom error: \(customError.errorDescription)")
                    completion(.failure(customError))
                }
            }
    }
}
