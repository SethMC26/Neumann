import Foundation
import TabularData

/// Axis with x y and z
enum Axis {
    case x
    case y
    case z
}

struct Row : Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let z: Double
}

/// AppModel is the model for the App and main model for the controllers of the app to interact with.
class AppModel: ObservableObject{
    // Data that the user has imported, nil is none has been imported yet
    private var data: DataFrame? = nil
    // Data that is being displayed currented(sliced dataframe from data)
    private var currDataDisplayed: DataFrame? = nil
    
    /// Map of axis and header associated with axis to display
    private var axes: [Axis: String] = [ : ]
    /// All headers of data
    private var headers: [String] = []
    
    @Published var rows: [Row] = []

    // TO:DO add visualization
    //private var vis : Object
    
    
    /// Set an Axis to be associated with a particular header
    /// - Parameters:
    ///   - axisToSet: Axis to set
    ///   - header: Header to set
    func setAxis(axisToSet: Axis, header: String) {
        axes[axisToSet] = header
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
        
        data = try DataFrame(contentsOfCSVFile: file)
        rows = []
        
        // get all the headers for each columns if one is nil
        headers = data?.columns.map {$0.name} ?? []
        
        //basic temporary code will need to update header setting later
        
        // check if we have less than three columns error out
        if headers.count < 3 {
            self.axes.removeAll()
            self.currDataDisplayed = nil
            throw AppError.notEnoughColumns
        }
        
        
        self.axes = [.x: headers[1], .y: headers[2], .z: headers[3]]
        self.currDataDisplayed = data?[[headers[1], headers[2], headers[3]]]  // slice by names
        
        var newRows: [Row] = []
        if let df = currDataDisplayed {
            for data in df.rows {
                //attempt to read data in each column as a double
                guard
                    let colOne = data[headers[1]] as? Double,
                    let colTwo = data[headers[2]] as? Double,
                    let colThree = data[headers[3]] as? Double
                else {
                    continue // skip row if we cannot unwrap it safely
                }
                newRows.append(Row(id: data.index, x:  colOne, y:  colTwo, z: colThree))
            }
        }
        
        //change state of row at the end once all rows loaded
        //UI is waiting for a state change on rows so we only want to change once its ready
        rows = newRows
    }
    
    /// Gets all of the headers of `self.data`
    /// - Returns: Headers of `self.data`
    func getHeaders() -> [String]? {
        return headers
    }
    
    
    /// Renders the data frame
    /// - Throws: AppError if no dataset loaded, x, y, z axis not set yet
    func render() throws {
        // load data frame and check if loaded
        guard let df = data else {
            throw AppError.noLoadedDataset
        }
        
        //get headers for x y and z axis throw an error if axis has not been set yet (cannot render visualization)
        guard let xLabel = axes[.x] else {
            throw AppError.xNotSet
        }
        
        guard let yLabel = axes[.y] else {
            throw AppError.yNotSet
        }
        
        guard let zLabel = axes[.z] else {
            throw AppError.zNotSet
        }
        
       
    }
}

enum AppError: Error {
    case noLoadedDataset
    case notEnoughColumns
    case xNotSet
    case yNotSet
    case zNotSet
}


