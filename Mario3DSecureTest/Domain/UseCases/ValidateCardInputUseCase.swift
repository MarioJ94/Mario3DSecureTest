import Foundation

struct ValidateCardInputParams {
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvv: String
}

protocol ValidateCardInputUseCaseProtocol {
    func run(params: ValidateCardInputParams) -> ValidateCardInputResult
}

final class ValidateCardInputUseCase: ValidateCardInputUseCaseProtocol {
    func run(params: ValidateCardInputParams) -> ValidateCardInputResult {
        let cardNumber = params.cardNumber
        let expiryMonth = params.expiryMonth
        let expiryYear = params.expiryYear
        let cvv = params.cvv
        let cardType = detectCardType(cardNumber)
        var errors = Set<CardValidationError>()
        guard !cardNumber.isEmpty, !expiryMonth.isEmpty, !expiryYear.isEmpty, !cvv.isEmpty else {
            return .init(cardType: cardType, state: .none, formattedYear: nil)
        }
        let expirationResult = validExpiration(expiryMonth: expiryMonth, expiryYear: expiryYear)
        if !expirationResult.valid {
            errors.insert(.invalidExpiration)
        }
        switch cardType {
        case .visa:
            let visaErrors = validateVisa(cardNumber, cvv: cvv)
            errors.formUnion(visaErrors)
            
        case .amex:
            let amexErrors = validateAmex(cardNumber, cvv: cvv)
            errors.formUnion(amexErrors)
            
        case .unknown:
            errors.formUnion([.unknownCard])
        }
        return .init(cardType: cardType, state: .result(errors), formattedYear: expirationResult.year)
    }
}

private extension ValidateCardInputUseCase {
    func detectCardType(_ cardNumber: String) -> CardType {
        if ["34", "37"].contains(where: cardNumber.hasPrefix) {
            return .amex
        } else if cardNumber.hasPrefix("4") {
            return .visa
        } else {
            return .unknown
        }
    }
    
    func validExpiration(expiryMonth: String, expiryYear: String) -> (valid: Bool, year: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        dateFormatter.locale = .current
        let date = dateFormatter.date(from: "\(expiryMonth)/\(expiryYear)")
        guard let date, date > Date() else {
            return (false, expiryYear)
        }
        dateFormatter.dateFormat = "yyyy"
        let formattedYear = dateFormatter.string(from: date)
        return (true, formattedYear)
    }
    
    func validateVisa(_ cardNumber: String, cvv: String) -> Set<CardValidationError> {
        var result = Set<CardValidationError>()
        if !validateDigits(cardNumber, count: 16) {
            result.insert(.invalidNumber)
        }
        if !validateDigits(cvv, count: 3) {
            result.insert(.invalidCVV)
        }
        return result
    }
    
    func validateAmex(_ cardNumber: String, cvv: String) -> Set<CardValidationError> {
        var result = Set<CardValidationError>()
        if !validateDigits(cardNumber, count: 15) {
            result.insert(.invalidNumber)
        }
        if !validateDigits(cvv, count: 4) {
            result.insert(.invalidCVV)
        }
        return result
    }
    
    func validateDigits(_ digits: String, count: Int) -> Bool {
        digits.filter(\.isNumber).count == count
    }
}
