///This class represents a number literal in our program 
struct NumNode : SyntaxNode {
    let num: Double
    
    /// Creates a new Num Node
    /// - Parameter token: Number Token(must have type `.NUMBER`) to create
    init(token: Token) throws{
        //check token type
        if token.type != .NUMBER {
            Log.Lang.fault("Bad type! \(token.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
        
        //assign temp value to safely unwrap(its a swift thing)
        guard let _num = Double(token.val) else {
            Log.Lang.fault("Could not cast token val: \(token.val) to Double")
            throw ParseError.InvalidNodeCreation
        }
        
        num = _num
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("IdNode[\(String(num))", identAmt)
    }
    
    func eval(_ x: Double, _ z: Double) -> Double {
        return num
    }
}
