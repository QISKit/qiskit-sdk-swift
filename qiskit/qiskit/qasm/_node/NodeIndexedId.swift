//
//  NodeIndexedId.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeIndexedId: Node {
    public var parameter: Node?
    public init(identifier: Node, parameter: Node) {
        super.init(type: .N_INDEXEDID)
        self.parameter = parameter
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
