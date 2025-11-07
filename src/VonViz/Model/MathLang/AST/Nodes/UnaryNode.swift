///This node represents a UnaryNode in our AST currenty only minus
struct UnaryNode : SyntaxNode {
    ///Node to minus
    let node : SyntaxNode
    
    ///Take the node and times negative 1 to it
    func eval(_ x: Double, _ y: Double) throws -> Double {
        let evalNode = try node.eval(x,y)
        return -1 * evalNode
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("UnaryNode[-](", identAmt)
        node.displaySubtree(identAmt: identAmt + 2)
        printIdent(")", identAmt)
    }
}
