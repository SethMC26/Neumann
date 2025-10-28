///This Node represents an IdNode in our AST either x or z
struct IdNode : SyntaxNode {
    ///Our ID Token
    let ID : Token
    
    /// Creates a new ID token
    /// - Parameter ID: Token of either .X or .Z type
    init(ID: Token) throws{
        self.ID = ID
        
        if ![.X, .Z].contains(ID.type) {
            Log.Lang.fault("Bad type! \(ID.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func eval(_ x: Double, _ z: Double) throws -> Double {
        switch (ID.type) {
        case .X:
            return x
        case .Z:
            return z
        default:
            Log.Lang.fault("Bad Type! \(ID.type) we should NEVER get here")
            self.displaySubtree(identAmt: 0) //display subtree to add debug
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("IdNode[\(ID.val)]", identAmt)
    }
}
