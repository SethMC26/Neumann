import Foundation
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
            case Optional<Any>.none, is NSNull:
                    // Missing row: represent as NaN
                    return .nan
            default:
                Log.Model.fault("Got value in column that was not numerical - should have already filtered these columns out")
                throw AppError.internalStateError
            }
        }
            .filter {!$0.isNaN } //remove all NaN from values
        
        //I hate swift coding patterns
        guard
            let minVal = values?.min(),
            let maxVal = values?.max()
        else {
            Log.Model.fault("Could not get min or max value - should never get here")
            throw AppError.internalStateError
        }
        
        //throw an error if min is greater than max
        if min > max {
            Log.Model.fault("Min greater than Max")
            Log.Model.info("Min greater than max should not happen here, likely an upstream issue in the code")
            throw AppError.minGreaterThanMax
        }
        
        self.min = minVal
        self.max = maxVal
        self.steps = autoStep()
        self.header = header
        Log.Model.debug("Setting \(header) Min: \(min), Max: \(max)")
    }
    /// Compute a human-friendly step size for an axis, given its min/max.
    /// - Parameters:
    /// - Returns: A step value rounded to 1/2/5 × 10ⁿ increments.
    private func autoStep() -> Double {
        //vibe coded
        let range = abs(max - min)
        guard range > 0 else { return 1 }

        // decide roughly how many ticks we want:
        // small range → few ticks, large range → more
        let targetTicks = Swift.max(3, Swift.min(10, Int(log10(range) * 2) + 4))

        // pick a step size that divides the range into that many parts
        let step = range / Double(targetTicks)

        // round to a “nice” value (1, 2, 5 × 10^n)
        let exp = floor(log10(step))
        let magnitude = pow(10.0, exp)
        let fraction = step / magnitude

        let roundedFraction: Double
        if fraction < 1.5 { roundedFraction = 1 }
        else if fraction < 3 { roundedFraction = 2 }
        else if fraction < 7 { roundedFraction = 5 }
        else { roundedFraction = 10 }

        return roundedFraction * magnitude
        }
}

