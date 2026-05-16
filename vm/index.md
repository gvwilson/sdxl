# A Virtual Machine

## Outline

- Architecture: instruction pointer (IP), 4 registers (R0–R3), 256-word memory
- Instructions are 3-byte records: opcode + up to 2 operands
- Instruction set: `ldc` (load constant), `ldm`/`stm` (load/store memory),
  `add`/`sub`/`mul` (register arithmetic), `beq` (branch if equal), `hlt`
- Assembler: `List Instr → Array UInt8` packs instructions into bytes
- VM state: `{ ip, regs, mem }` as arrays; `step` fetches, decodes, executes one instruction
- Run loop calls `step` until `hlt` or IP out of bounds

## Code

[%inc code.lean %]
