import TabularData


/// AxisInfo is a struct holding information for the x y or z axis displayed
/// `header` - Column name of this axis
/// `max` - Max value in this column
/// `min` - Min value in this column
/// `steps` - Steps to display for this column
struct AxisInfo {
    var header: String = ""
    var max: Double = 50
    var min: Double = -50
    var steps: Double = 1.0
    
    /// Gets the domain of this function
    /// - Returns: Closed range between min...max
    func getDomain() throws -> ClosedRange<Double> {
        return min...max
    }
    
    /// Set the value of this struct, automatically sets min and max based on the input column
    /// - Parameters:
    ///   - header: Name of column
    ///   - column: Column with values to set
    mutating func setValues(header: String, column: AnyColumn) throws {
        // column could be any so we will cast it to doubles
        // This function should never have the ability to have non-numerical columns passed into it 
        let values = try? column.compactMap { value -> Double? in
            switch value {
            case let v as Double:
                return v
            case let v as Float:
                return Double(v)
            case let v as Int:
                return Double(v)
            default:
                Log.Model.fault("Got value in column that was not numerical - should have already filtered these columns out")
                throw AppError.internalStateError
            }
        }
        
        //I hate swift coding patterns
        guard
            let minVal = values?.min(),
            let maxVal = values?.max()
        else {
            Log.Model.fault("Could not get min or max value - should never get here")
            throw AppError.internalStateError
        }

        self.min = minVal
        self.max = maxVal
        self.header = header
        Log.Model.debug("Setting \(header) Min: \(min), Max: \(max)")
    }

}

