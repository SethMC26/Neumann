import Foundation
import TabularData

/// AppModel is the model for the App and main model for the controllers of the app to interact with.
class AppModel: ObservableObject{
    /// Make display limit user-configurable
    @Published var displayLimit: Int {
        didSet {
            // Optionally persist value
            UserDefaults.standard.set(displayLimit, forKey: "displayLimit")
        }
    }
    /// Data that the user has imported, nil is none has been imported yet
    private var data: DataFrame? = nil
    
    /// Map of axis and header associated with axis to display
    private var axes: [Axis: AxisInfo] = [
        .x : AxisInfo(header: "X Axis"),
        .y : AxisInfo(header: "Y Axis"),
        .z : AxisInfo(header: "Z Axis")
    ]
    /// All headers of columns that can be changed
    @Published var headers: [String] = []
    /// Rows of dataset updated when new file loaded or axis to display is changed
    @Published var rows: [Row] = []
    
    /// Set an Axis to be associated with a particular header
    func setAxis(axisToSet: Axis, header: String) throws {
        Log.Model.debug("Setting axis to \(axisToSet) to \(header)")
        guard let df = data else {
            Log.Model.error("No dataset loaded")
            throw AppError.noLoadedDataset
        }
        
        try axes[axisToSet]?.setValues(header: header, column: df[header])
        try render()
    }
    
    func getAxisHeader(axisToGet: Axis) -> String?{
        return axes[axisToGet]?.header
    }
    
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
        
        guard let df = data else {
            Log.Model.fault("No dataframe parsed - should have already exited function")
            throw AppError.noLoadedDataset }
        
        var col_names: [String] = []
        
        Log.Model.debug("Getting headers and doing type conversions to doubles ")
        for col in df.columns {
            let type = col.wrappedElementType
            if type == Int.self || type == Float.self || type == Double.self {
                col_names.append(col.name)
            }
        }
        
        if col_names.count < 3 {
            Log.Model.info("Loaded dataset does not have enough columns with numeric values")
            throw AppError.notEnoughColumns
        }
        
        headers = col_names
        
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
        guard let df = data else {
            Log.Model.error("No dataset loaded while rendering")
            throw AppError.noLoadedDataset
        }
        
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
            let colOne = try asDouble(data[xLabel])
            let colTwo = try asDouble(data[yLabel])
            let colThree = try asDouble(data[zLabel])
            
            if colOne.isNaN || colTwo.isNaN || colThree.isNaN {
                Log.Model.debug("Row contains a NaN skipping")
                continue
            }
            newRows.append(Row(id: data.index, x:  colOne, y:  colTwo, z: colThree))
            
            if newRows.count >= displayLimit {
                Log.Model.info("Reached display limit \(displayLimit)")
                break
            }
        }
        
        Log.Model.debug("Render complete publishing new data")
        rows = newRows
    }
    
    func getAxisRange(axis: Axis) throws -> ClosedRange<Double> {
        Log.Model.info("Getting the range for axis \(axis)")
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
            axisInfo.min = min!
        }
        
        if max != nil {
            axisInfo.max = max!
        }
        
        if steps != nil {
            axisInfo.steps = steps!
        }
        
        if (axisInfo.min > axisInfo.max) {
            Log.Model.error("Min value is greater than max cannot set Domain")
            throw AppError.minGreaterThanMax
        }
        
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
        case Optional<Any>.none, is NSNull:
            return Double.nan
        default:
            Log.Model.fault("Non-numeric type - we should have already filtered these columns out")
            throw AppError.internalStateError
        }
    }
    
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
