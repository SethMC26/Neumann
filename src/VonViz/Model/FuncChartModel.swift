import Foundation
import Charts

class FuncChartModel: ObservableObject {
    @Published var ast: SyntaxTree
    
    init(input: String) throws {
        //get syntax tree
        ast = try Parser(input: input).parse()
        ast.displaytree()
    }
    
    func setInput(_ input: String) throws {
        //get syntax tree
        ast = try Parser(input: input).parse()
        ast.displaytree()
    }
}
