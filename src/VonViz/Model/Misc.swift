///This file holds miscalleounus enums and structs that are small and uncomplex for use in Model.
///

///Errors that can be thrown by our app
enum AppError: Error {
    case noLoadedDataset
    case notEnoughColumns
    case headerNotRecongized
    case internalStateError
    case minGreaterThanMax
}


/// Axis with x y and z
enum Axis {
    case x
    case y
    case z
}

/// Row of data for use in Chart3D
struct Row : Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let z: Double
}

