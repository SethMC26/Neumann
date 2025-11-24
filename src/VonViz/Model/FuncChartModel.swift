import Foundation
import Charts

/// View model for the 3D function chart (surface plot).
/// Handles parsing the input function and managing the X/Y/Z axes.
/// Comments/Documentation created by chatGPT
class FuncChartModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Parsed syntax tree of the user's math function.
    @Published var ast: SyntaxTree
    
    /// Information for the X axis (range, step size, etc.)
    @Published var xAxis: AxisInfo
    
    /// Information for the Y axis.
    @Published var yAxis: AxisInfo
    
    /// Information for the Z axis.
    @Published var zAxis: AxisInfo
    
    // MARK: - Initialization
    
    /// Creates a new model and parses the initial input function.
    init(input: String) throws {
        // Initialize default axis ranges
        xAxis = AxisInfo(header: "x", max: 5.0, min: -5.0, steps: 1.0)
        yAxis = AxisInfo(header: "y", max: 5.0, min: -5.0, steps: 1.0)
        zAxis = AxisInfo(header: "z", max: 5.0, min: -5.0, steps: 1.0)
        
        // Parse the input string into an abstract syntax tree (AST)
        ast = try Parser(input: input).parse()
    }
    
    // MARK: - Function Handling
    
    /// Updates the parsed function when the user enters a new expression.
    func setInput(_ input: String) throws {
        Log.Model.debug("Parsing string: \(input) in grammar")
        ast = try Parser(input: input).parse()
        //ast.displaytree() uncomment for debugging
    }
    
    // MARK: - Axis Handling
    
    /// Updates one of the chart axes with new range and step values.
    ///
    /// - Parameters:
    ///   - axis: The axis to modify (`.x`, `.y`, or `.z`)
    ///   - max:  The new maximum value for the axis
    ///   - min:  The new minimum value for the axis
    ///   - steps: The new step size between ticks
    /// - Throws: `AppError.minGreaterThanMax` if `min` is greater than `max`
    func setAxis(axis: Axis, max: Double, min: Double, steps: Double) throws {
        // Validate min/max relationship
        guard min <= max else {
            Log.Model.error("Min value is greater than max — cannot set values")
            throw AppError.minGreaterThanMax
        }
        
        Log.Model.debug("funcChart: Setting axis: \(axis) to Max: \(max) Min: \(min) Steps: \(steps)")
        // Update the appropriate axis
        switch axis {
        case .x:
            xAxis = AxisInfo(header: "x", max: max, min: min, steps: steps)
        case .y:
            yAxis = AxisInfo(header: "y", max: max, min: min, steps: steps)
        case .z:
            zAxis = AxisInfo(header: "z", max: max, min: min, steps: steps)
        }
    }
}

