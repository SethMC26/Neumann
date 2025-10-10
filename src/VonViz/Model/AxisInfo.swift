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
    
    func getDomain() throws -> ClosedRange<Double> {
        return min...max
    }
    
    mutating func setValues(header: String, column: AnyColumn) throws {
        let values = column.compactMap { value -> Double? in
            switch value {
            case let v as Double:
                return v
            case let v as Float:
                return Double(v)
            case let v as Int:
                return Double(v)
            default:
                return nil
            }
        }
        
        //I hate swift coding patterns
        guard
            let minVal = values.min(),
            let maxVal = values.max()
        else {
            throw AppError.internalStateError
        }

        self.min = minVal
        self.max = maxVal
        self.header = header
        Log.Model.debug("Setting \(header) Min: \(min), Max: \(max)")
    }

}

