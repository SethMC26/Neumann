///Syntax Node class takes heavy inspiration from Zachary Kissel's class Programming Languages CSC3120

///Interface of all Syntax nodes in our AST
protocol SyntaxNode {
    /// Display the subtree of our syntaxNode
    /// - Parameter identAmt: Amount of indentation for the subtree
    func displaySubtree(identAmt: Int)
    /// Evaluate this node of the subtree.
    /// F(x, z) = y where x and z are the inputs and y is the point at this syntax node
    /// - Parameters:
    ///   - x: x value to sample
    ///   - z: z value to sample
    /// - Returns: y or result of this syntax node
    func eval(_ x: Double,_ y: Double) throws -> Double
}

extension SyntaxNode {
    /// Prints idented message
    /// - Parameters:
    ///   - msg: Message to print
    ///   - identAmt: Amount to ident message
    func printIdent(_ msg: String,_ identAmt: Int) {
        let indent = String(repeating: " ", count: identAmt)
        print("\(indent)\(msg)")
    }
}
