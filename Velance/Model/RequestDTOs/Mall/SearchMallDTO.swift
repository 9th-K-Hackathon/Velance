import Foundation
import Alamofire

//MARK: - 카카오맵 화면에서 키워드로 식당 검색 시 사용하는 Model -> MapManager.shared.searchByKeyword()

struct SearchMallDTO {
    
    /// X 좌표값, 경위도인 경우 longitude (경도)
    let x: String = "128.6104881544238"
    
    /// Y 좌표값, 경위도인 경우 latitude(위도)
    let y: String = "35.888949648310486"
    
    /// 중심 좌표부터의 반경거리 - 미터 기준
    let radius: String = "10000"
    
    /// 사용자 검색 매장
    var query: String?
    
    init(query: String) {
        
        self.query = query
        
        /// Initialize parameters
        parameters["x"] = self.x
        parameters["y"] = self.y
        parameters["radius"] = self.radius
        parameters["query"] = self.query
    }
    
    // 아래가 실제 쓰이는 것
    init(query: String, x: String, y: String) {
        
        /// Initialize parameters
        parameters["x"] = x
        parameters["y"] = y
        parameters["radius"] = self.radius
        parameters["query"] = query
    }

    var parameters: Parameters = [:]
    
    let headers: HTTPHeaders = [
        "Authorization": "KakaoAK \(KakaoAPIKey.API_Key)"
    ]
}
