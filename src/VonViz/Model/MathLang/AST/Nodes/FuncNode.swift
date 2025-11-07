import Foundation

///This struct represents a math Function in our AST
struct FuncNode : SyntaxNode {
    ///Syntax Node that is inside of our function
    let node: SyntaxNode
    ///Function this node represents
    let function: Token
    
    /// Creates a new Func Node
    /// - Parameters:
    ///   - node: Node that is inside our function
    ///   - function: Function of this node(sin cos or tan)
    init(node: SyntaxNode, function: Token) throws {
        self.node = node
        self.function = function
        
        if ![.SIN, .COS, .TAN].contains(function.type) {
            Log.Lang.fault("Bad type! \(function.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("FuncNode[\(function)](", identAmt)
        node.displaySubtree(identAmt: identAmt + 2)
        printIdent(")", identAmt)
    }
    
    func eval(_ x: Double, _ y: Double) throws -> Double{
        //get val of node inside our function
        let val = try node.eval(x, y)
        
        //return value from our function
        switch (function.type) {
        case .SIN:
            return sin(val)
        case .COS:
            return cos(val)
        case .TAN:
            return tan(val)
        default:
            Log.Lang.fault("Bad Type! \(function.type) we should NEVER get here")
            self.displaySubtree(identAmt: 0) //display subtree to add debug
            throw ParseError.InvalidNodeCreation
        }
        
    }
}

