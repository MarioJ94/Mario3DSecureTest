enum CardValidationError: Error {
    case invalidNumber, invalidCVV, invalidExpiration, unknownCard
}
