import Foundation
import SwiftUI
import TabularData

/// AppModel is the model for the App and main model for the controllers of the app to interact with.
class DataChartModel: ObservableObject{
    /// limit to data that can be displayed
    private let DISPLAY_LIMIT: Int = 1000
    /// Data that the user has imported, nil is none has been imported yet
    private var data: DataFrame? = nil
    
    /// Map of axis and header associated with axis to display
    private var axes: [Axis: AxisInfo] = [
        .x : AxisInfo(header: "X Axis"),
        .y : AxisInfo(header: "Y Axis"),
        .z : AxisInfo(header: "Z Axis")
    ]
    /// Make display limit user-configurable
    @Published var displayLimit: Int {
       didSet {
           // Optionally persist value
           UserDefaults.standard.set(displayLimit, forKey: "displayLimit")
       }
    }
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
        guard let df = data else {
            Log.Model.error("No dataset loaded")
            throw AppError.noLoadedDataset
        }
        
        try axes[axisToSet]?.setValues(header: header, column: df[header])
        try render()
    }
    
    /// Get the Header associated with a certain Axis
    /// - Parameter axisToGet: Axis to get
    /// - Returns: String of header associated with access, nil if no access is set
    func getAxisHeader(axisToGet: Axis) -> String?{
        return axes[axisToGet]?.header
    }
    
    /// Ingests a file turning a file into an internal dataframe representation ready for visualization. This function will handle
    /// the inputting of datasets to the visualization.
    /// - Parameter url: URL of local file to load
    func ingestFile(file: URL) throws {
        Log.Model.debug("Loading file: \(file)")
        
        //remove old data
        data = try DataFrame(contentsOfCSVFile: file)
        rows = []
        
        //reset axes map
        axes = [
            .x : AxisInfo(),
            .y : AxisInfo(),
            .z : AxisInfo()
        ]
        
        //Should not error out here but include this check to please the compiler
        guard let df = data else {
            Log.Model.fault("No dataframe parsed - should have already exited function")
            throw AppError.noLoadedDataset }
        
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
            Log.Model.info("Loaded dataset does not have enough columns with numeric values")
            throw AppError.notEnoughColumns
        }
        
        headers = col_names
        
        //set displayed data to first three applicable columns
        try axes[.x]?.setValues(header: col_names[0], column: df[col_names[0]])
        try axes[.y]?.setValues(header: col_names[1], column: df[col_names[1]])
        try axes[.z]?.setValues(header: col_names[2], column: df[col_names[2]])
        
        Log.Model.debug("Set default Axis \(axes) and sliced dataframe")

        try render()
    }
    
    
    /// Renders the data frame
    /// - Throws: AppError if no dataset loaded, x, y, z axis not set yet
    func render() throws {
        Log.Model.info("Rendering data")
        // load data frame and check if loaded
        guard let df = data else {
            Log.Model.error("No dataset loaded while rendering")
            throw AppError.noLoadedDataset
        }
        
        //get headers for x y and z axis throw an error if axis has not been set yet (cannot render visualization)
        guard
            let xLabel: String = axes[.x]?.header,
            let yLabel: String = axes[.y]?.header,
            let zLabel: String = axes[.z]?.header
        else {
            Log.Model.fault("Header not set yet for an axis - header should always be set")
            throw AppError.headerNotRecongized
        }
        
        var newRows: [Row] = []
        Log.Model.debug("Attempting type conversion on each row")
        for data in df.rows {
            //attempt to read data in each column as a double
            let colOne = try asDouble(data[xLabel])
            let colTwo = try asDouble(data[yLabel])
            let colThree = try asDouble(data[zLabel])
            
            //if value is NaN skip the row
            //may want to make more sophisticated or add settings to configure this later
            if colOne.isNaN || colTwo.isNaN || colThree.isNaN {
                Log.Model.debug("Row contains a NaN skipping")
                continue
            }
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
        //should never happen since we automatically set x, y, z axes when loading dataset
        guard let axisInfo = axes[axis] else {
            Log.Model.error("No dataset loaded")
            throw AppError.noLoadedDataset
        }

        return try axisInfo.getDomain()
    }
    
    func setAxisDomain(axis: Axis, min: Double?, max: Double?, steps: Double?) throws {
        guard var axisInfo = axes[axis] else {
            Log.Model.fault("Axis not loaded - should never happen")
            throw AppError.headerNotRecongized
        }
        
        if min != nil {
            axisInfo.min = min! //force unwrap we already checked if nil
        }
        
        if max != nil {
            axisInfo.max = max! //force unwrap we already checked if nil
        }
        
        if steps != nil {
            axisInfo.steps = steps! //force unwrap we already checked if nil
        }
        
        //check if min > max if so error out before saving axisInfo to map
        if (axisInfo.min > axisInfo.max) {
            Log.Model.error("Min value is greater than max cannot set Domain")
            throw AppError.minGreaterThanMax
        }
        
        //add back to map structs are pass by copy
        axes[axis] = axisInfo
        try render()
    }
    
    func getAxisInfo(axis: Axis) throws -> AxisInfo{
        Log.Model.debug("Getting Axis info for \(axis)")
        guard let axisInfo = axes[axis] else {
            Log.Model.error("Axis not loaded")
            throw AppError.headerNotRecongized
        }
        
        return axisInfo
    }
    /// chatGPT generated function to return a number value as a double
    private func asDouble(_ value: Any?) throws -> Double {
        switch value {
        case let d as Double: return d
        case let i as Int:    return Double(i)
        case let f as Float:  return Double(f)
        //if we are missing a value then return NaN
        case Optional<Any>.none, is NSNull:
            return Double.nan
        //throw internalStateError we should only be calling this function on values we know will be an Int Double or Float
        default:
            Log.Model.fault("Non-numeric type - we should have already filtered these columns out")
            throw AppError.internalStateError
        }
    }
    
    
    @Published var displayeLimit: Int = 1000
    /// Init: load displayLimit from UserDefaults if available
    init() {
        let savedLimit = UserDefaults.standard.integer(forKey: "displayLimit")
        if savedLimit > 0 {
            self.displayLimit = savedLimit
        } else {
            self.displayLimit = 1000
        }
    }
}
