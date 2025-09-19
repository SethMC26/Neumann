import Foundation
import TabularData

/// Axis with x y and z
enum Axis {
    case x
    case y
    case z
}

class AppModel {
    private var axes: [Axis: String] = [ : ]
    private var data: DataFrame? = nil
    private var headers: [String] = []
    private var currDataDisplayed: DataFrame? = nil

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
        
        // get all the headers for each columns if one is nil
        headers = data?.columns.map {$0.name} ?? []
        
        axes = [:] // reset loaded axis
        currDataDisplayed = nil // reset current data being displayed
        
        //set headers
        
    }
    
    func getHeaders() -> [String]? {
        return headers
    }
    
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
        
        currDataDisplayed = df[[xLabel, yLabel, zLabel]]
        
        //todo add other visualization rendering of 3d objectsas
    }
}

enum AppError: Error {
    case noLoadedDataset
    case xNotSet
    case yNotSet
    case zNotSet
}


