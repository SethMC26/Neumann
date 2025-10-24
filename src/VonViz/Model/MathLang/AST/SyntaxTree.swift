struct SyntaxTree {
    let nodes: [ SyntaxNode ]
    
    init(nodes: [SyntaxNode]) {
        self.nodes = nodes
    }
    
    func displaytree() {
        print("AST(")
        for node in nodes {
            node.displaySubtree(identAmt: 1)
        }
        print(")")
    }

    func eval(_ x: Double, _ z: Double) throws -> Double {
        var num: Double = 0.0
        for node in nodes {
            num += try node.eval(x, z)
        }
        return num
    }

}
