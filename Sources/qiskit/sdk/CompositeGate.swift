// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation

/**
 Composite gate, a sequence of unitary gates.
 */
public protocol CompositeGate: Gate {

    var compositeGateComponent: CompositeGateComponent { get }
}

extension CompositeGate {

    public var description: String {
        var text = ""
        for statement in self.compositeGateComponent.data {
            text.append("\n\(statement.description);")
        }
        return text
    }

    /**
     Test if this gate's circuit has the register.
     */
    public func has_register(_ register: Register) throws -> Bool {
        return self.circuit.has_register(register)
    }

    /**
     Apply any modifiers of this gate to another composite.
     */
    func _modifiers(_ gate: Gate) throws {
        if self.compositeGateComponent.inverse_flag {
            gate.inverse()
        }
        try self.instructionComponent._modifiers(gate)
    }

    /**
     Attach gate.
     */
    func _attach(_ gate: Gate) -> Gate {
        self.compositeGateComponent.data.append(gate)
        return gate
    }

    /**
     Attach barrier.
     */
    func _attach(_ barrier: Barrier) -> Barrier {
        self.compositeGateComponent.data.append(barrier)
        return barrier
    }

    /**
     Raise exception if q is not an argument or not qreg in circuit.
     */
    func _check_qubit(_ qubit: QuantumRegisterTuple) throws {
        try self.circuit._check_qubit(qubit)
        for arg in self.args {
            if let tuple = arg as? QuantumRegisterTuple {
                if tuple.register.name == qubit.register.name &&
                    tuple.index == qubit.index {
                    return
                }
            }
        }
        throw QISKitError.notQubitGate(qubit: qubit)
    }

    /**
     Raise exception if quantum register is not in this gate's circuit.
     */
    func _check_qreg(_ register: QuantumRegister) throws {
        try self.circuit._check_qreg(register)
    }

    /**
     Raise exception if classical register is not in this gate's circuit.
     */
    func _check_creg(_ register: ClassicalRegister) throws {
        try self.circuit._check_creg(register)
    }

    /**
     Invert this gate.
     */
    @discardableResult
    public func inverse() -> Self {
        var array:[Instruction] = []
        for gate in self.compositeGateComponent.data.reversed() {
            array.append(gate.inverse())
        }
        self.compositeGateComponent.data = array
        self.compositeGateComponent.inverse_flag = !self.compositeGateComponent.inverse_flag
        return self
    }

    /**
     Add classical control register.
     */
    public func c_if(_ c: ClassicalRegister, _ val: Int) throws -> Instruction {
        var array:[Instruction] = []
        for gate in self.compositeGateComponent.data {
            array.append(try gate.c_if(c, val))
        }
        self.compositeGateComponent.data = array
        return self
    }

    /**
     Add controls to this gate.
     */
    public func q_if(_ qregs:[QuantumRegister]) -> Instruction {
        var array:[Instruction] = []
        for instruction in self.compositeGateComponent.data {
            array.append(instruction.q_if(qregs))
        }
        self.compositeGateComponent.data = array
        return self
    }

    public func reapply(_ circ: QuantumCircuit) throws {
        fatalError("reapply not implemented")
    }

    private func append(_ gate: Gate) -> CompositeGate {
        self.compositeGateComponent.data.append(gate)
        gate.instructionComponent.circuit = self.instructionComponent.circuit
        return self
    }
}
