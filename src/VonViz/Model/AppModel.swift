import Foundation
import TabularData

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

/// AppModel is the model for the App and main model for the controllers of the app to interact with.
class AppModel: ObservableObject{
    /// limit to data that can be displayed
    private let DISPLAY_LIMIT: Int = 1000
    /// Data that the user has imported, nil is none has been imported yet
    private var data: DataFrame? = nil
    /// Data that is being displayed currented(sliced dataframe from data)
    private var currDataDisplayed: DataFrame? = nil
    
    /// Map of axis and header associated with axis to display
    private var axes: [Axis: String] = [ : ]
    /// All headers of columns that can be changed
    @Published var headers: [String] = []
    /// Rows of dataset updated when new file loaded or axis to display is changed
    @Published var rows: [Row] = []
    
    /// Set an Axis to be associated with a particular header
    /// - Parameters:
    ///   - axisToSet: Axis to set
    ///   - header: Header to set
    /// - Throws:
    ///      - AppError from render functions
    func setAxis(axisToSet: Axis, header: String) throws {
        Log.Model.debug("Setting axis to \(axisToSet) to \(header)")
        axes[axisToSet] = header
        try render()
    }
    
    /// Get the Header associated with a certain Axis
    /// - Parameter axisToGet: Axis to get
    /// - Returns: String of header associated with access, nil if no access is set
    func getAxisHeader(axisToGet: Axis) -> String?{
       return axes[axisToGet]
    }
    
    /// Ingests a file turning a file into an internal dataframe representation ready for visualization. This function will handle
    /// the inputting of datasets to the visualization.
    /// - Parameter url: URL of local file to load
    func ingestFile(file: URL) throws {
        Log.Model.debug("Loading file: \(file)")
        
        //remove old data
        data = try DataFrame(contentsOfCSVFile: file)
        currDataDisplayed = nil
        rows = []
        axes.removeAll()
        
        //Should not error out here but include this check to please the compiler
        guard let df = data else { throw AppError.noLoadedDataset }
        
        // names of the columns with numbers that a user can select
        var col_names: [String] = []
        
        Log.Model.debug("Getting headers and doing type conversions to doubles ")
        //attempt to automatically set axes
        for col in df.columns {
            let type = col.wrappedElementType
            // add column if it is a number type
            // @note in the future we could include int8, int16, int32 types but im not sure if this is necessary
            if type == Int.self || type == Float.self || type == Double.self {
                col_names.append(col.name)
            }
            
        }
        
        // if there are less than 3 columns with numbers in them dataset cannot be loaded
        if col_names.count < 3 {
            throw AppError.notEnoughColumns
        }
        
        headers = col_names
        //set displayed data to first three applicable columns
        axes = [Axis.x: col_names[0], Axis.y: col_names[1], Axis.z: col_names[2]]
        self.currDataDisplayed = df[[col_names[0], col_names[1], col_names[2]]]
        Log.Model.debug("Set default Axis \(axes) and sliced dataframe")

        try render()
        
    }
    
    
    /// Renders the data frame
    /// - Throws: AppError if no dataset loaded, x, y, z axis not set yet
    func render() throws {
        Log.Model.info("Rendering data")
        // load data frame and check if loaded
        guard let df = data else {
            throw AppError.noLoadedDataset
        }
        
        //get headers for x y and z axis throw an error if axis has not been set yet (cannot render visualization)
        guard
            let xLabel = axes[.x],
            let yLabel = axes[.y],
            let zLabel = axes[.z]
        else {
            throw AppError.headerNotRecongized
        }
        
        var newRows: [Row] = []
        Log.Model.debug("Attempting type conversion on each row")
        for data in df.rows {
            //attempt to read data in each column as a double
            let colOne = try asDouble(data[xLabel])
            let colTwo = try asDouble(data[yLabel])
            let colThree = try asDouble(data[zLabel])
            
            newRows.append(Row(id: data.index, x:  colOne, y:  colTwo, z: colThree))
            
            if newRows.count > DISPLAY_LIMIT {
                Log.Model.info("Reached display limit \(DISPLAY_LIMIT)")
                break
            }
        }
        
        //change state of row at the end once all rows loaded
        Log.Model.debug("Render complete publishing new data")
        //UI is waiting for a state change on rows so we only want to change once its ready
        rows = newRows

    }
    
    /// Get a closed range from min to max of a columns values for a particular axis
    /// - Parameter axis: Axis to get range for
    /// - Returns: Closed Range of doubles for that access
    func getAxisRange(axis: Axis) throws -> ClosedRange<Double> {
        Log.Model.info("Getting the range for axis \(axis)")
        //should never happen button should only appear once dataset loaded
        guard let df = data else {
                throw AppError.noLoadedDataset
            }
        //should never happen since we automatically set x, y, z axes when loading dataset
        guard let columnName = axes[axis] else {
            throw AppError.noLoadedDataset
        }
        
        //get column
        let col = df[columnName]
        
        //cast column to correct type
        //columns should always have type int double or float type since those are the ones we provide headers for
        switch col.wrappedElementType {
        case is Double.Type:
            let typedCol: Column<Double> = df[columnName, Double.self]
            guard
                let min = typedCol.min(),
                let max = typedCol.max()
            else {
                throw AppError.internalStateError
            }
            
            return min...max
        case is Int.Type:
            let typedCol: Column<Int> = df[columnName, Int.self]
            guard
                let min = typedCol.min(),
                let max = typedCol.max()
            else {
                throw AppError.internalStateError
            }
            
            return Double(min)...Double(max)
        case is Float.Type:
            let typedCol: Column<Float> = df[columnName, Float.self]
            guard
                let min = typedCol.min(),
                let max = typedCol.max()
            else {
                throw AppError.internalStateError
            }
            
            return Double(min)...Double(max)
        default:
            throw AppError.internalStateError
        }

        
    }
    
    /// chatGPT generated function to return a number value as a double
    private func asDouble(_ value: Any?) throws -> Double {
        switch value {
        case let d as Double: return d
        case let i as Int:    return Double(i)
        case let f as Float:  return Double(f)
        //throw internalStateError we should only be calling this function on values we know will be an Int Double or Float
        default: throw AppError.internalStateError
        }
    }
}

enum AppError: Error {
    case noLoadedDataset
    case notEnoughColumns
    case headerNotRecongized
    case internalStateError
}


