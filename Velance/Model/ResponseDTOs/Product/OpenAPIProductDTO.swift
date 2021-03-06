import Foundation

struct OpenAPIProductDTO: Decodable {
    
    let results: OpenAPIProductResult
    
    enum CodingKeys: String, CodingKey {
        case results = "C002"
    }
}

struct OpenAPIProductResult: Decodable {
    
    let totalCount: String
    let productList: [OpenAPIProductList]?
    let searchResult: OpenAPISearchResult
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case productList = "row"
        case searchResult = "RESULT"
    }
}


struct OpenAPIProductList: Decodable {
    
    let productName: String
    let productListReportNumber: String
    let rawMaterialNames: String
    
    let prmsDt, lcnsNo: String
    let bsshNm, prdlstDcnm: String

    enum CodingKeys: String, CodingKey {
        case productListReportNumber = "PRDLST_REPORT_NO"
        case rawMaterialNames = "RAWMTRL_NM"
        case prmsDt = "PRMS_DT"
        case lcnsNo = "LCNS_NO"
        case productName = "PRDLST_NM"
        case bsshNm = "BSSH_NM"
        case prdlstDcnm = "PRDLST_DCNM"
    }
}

struct OpenAPISearchResult: Decodable {
    
    let msg, code: String

    enum CodingKeys: String, CodingKey {
        case msg = "MSG"
        case code = "CODE"
    }
}
