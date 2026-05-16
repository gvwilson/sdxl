-- Register index (0–3)
abbrev Reg := Fin 4

-- Instruction set
inductive Instr where
  | Ldc : Reg → UInt8 → Instr          -- R[i] := constant
  | Ldm : Reg → UInt8 → Instr          -- R[i] := mem[addr]
  | Stm : UInt8 → Reg → Instr          -- mem[addr] := R[i]
  | Add : Reg → Reg → Reg → Instr      -- R[i] := R[j] + R[k]
  | Sub : Reg → Reg → Reg → Instr      -- R[i] := R[j] - R[k]
  | Mul : Reg → Reg → Reg → Instr      -- R[i] := R[j] * R[k]
  | Beq : Reg → Reg → UInt8 → Instr    -- if R[i] == R[j] then IP := addr
  | Hlt : Instr
  deriving Repr

-- VM state
structure VMState where
  ip   : Nat
  regs : Array Int    -- 4 registers
  mem  : Array Int    -- 256 words
  halt : Bool
  deriving Repr

def initState : VMState :=
  { ip := 0, regs := Array.mkArray 4 0, mem := Array.mkArray 256 0, halt := false }

def getReg (s : VMState) (r : Reg) : Int := s.regs[r.val]!
def setReg (s : VMState) (r : Reg) (v : Int) : VMState :=
  { s with regs := s.regs.set! r.val v }
def getMem (s : VMState) (a : UInt8) : Int := s.mem[a.toNat]!
def setMem (s : VMState) (a : UInt8) (v : Int) : VMState :=
  { s with mem := s.mem.set! a.toNat v }

-- Execute one instruction
def step (prog : Array Instr) (s : VMState) : VMState :=
  if s.ip >= prog.size then { s with halt := true }
  else match prog[s.ip]! with
  | Instr.Ldc r k   => { setReg s r k.toNat    with ip := s.ip + 1 }
  | Instr.Ldm r a   => { setReg s r (getMem s a) with ip := s.ip + 1 }
  | Instr.Stm a r   => { setMem s a (getReg s r) with ip := s.ip + 1 }
  | Instr.Add d a b => { setReg s d (getReg s a + getReg s b) with ip := s.ip + 1 }
  | Instr.Sub d a b => { setReg s d (getReg s a - getReg s b) with ip := s.ip + 1 }
  | Instr.Mul d a b => { setReg s d (getReg s a * getReg s b) with ip := s.ip + 1 }
  | Instr.Beq i j a =>
      if getReg s i == getReg s j then { s with ip := a.toNat }
      else { s with ip := s.ip + 1 }
  | Instr.Hlt       => { s with halt := true }

-- Run until halt (bounded by fuel)
def run (prog : Array Instr) (fuel : Nat) (s : VMState) : VMState :=
  match fuel with
  | 0 => s
  | n + 1 => if s.halt then s else run prog n (step prog s)

def runProg (prog : Array Instr) : VMState :=
  run prog 10000 initState

-- Tests ----------------------------------------------------------------
-- Program: R0 := 3; R1 := 4; R2 := R0 + R1; hlt
-- Expected: R2 = 7
def addProg : Array Instr := #[
  Instr.Ldc ⟨0, by omega⟩ 3,
  Instr.Ldc ⟨1, by omega⟩ 4,
  Instr.Add ⟨2, by omega⟩ ⟨0, by omega⟩ ⟨1, by omega⟩,
  Instr.Hlt
]

#eval (runProg addProg).regs   -- expected: #[3, 4, 7, 0]

#guard (runProg addProg).regs[2]! == 7
