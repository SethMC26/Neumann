import Foundation

///This node represents an operation in our abstract syntax tree
struct OpNode : SyntaxNode {
    ///Left side of the operation
    let leftOp: SyntaxNode
    ///Right side of the operation
    let rightOp: SyntaxNode
    ///Operation to preform
    let op: Token
    
    /// Creates a new operation node
    /// - Parameters:
    ///   - LeftOp: Left side of operation
    ///   - RightOp: Right side of operation
    ///   - op: Operation to preform
    init(LeftOp: SyntaxNode, RightOp: SyntaxNode, op: Token) throws {
        self.leftOp = LeftOp
        self.rightOp = RightOp
        self.op = op
        
        if ![.ADD, .SUB, .MULT, .DIV, .EXP, .ROOT].contains(op.type) {
            Log.Lang.fault("Bad type! \(op.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func eval(_ x: Double,_ y: Double) throws -> Double {
        let leftVal: Double = try leftOp.eval(x, y)
        let rightVal: Double = try rightOp.eval(x, y)
        
        switch(op.type) {
        case .ADD:
            return leftVal + rightVal
        case .SUB:
            return leftVal - rightVal
        case .MULT:
            return leftVal * rightVal
        case .DIV:
            return leftVal / rightVal
        case .EXP:
            return pow(leftVal, rightVal)
        case .ROOT:
            //N th root or inverse exponential
            return pow(leftVal, (1/rightVal))
        default:
            Log.Lang.fault("Bad Type! \(op.type) we should NEVER get here")
            self.displaySubtree(identAmt: 0) //display subtree to add debug
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("OpNode[\(op.val)](", identAmt)
        leftOp.displaySubtree(identAmt: identAmt + 2)
        rightOp.displaySubtree(identAmt: identAmt + 2)
        printIdent(")", identAmt )
    }
}
