pub const NOP: u16 = 0x00;

/// mov r1, 0xdead; -> r1
pub const MOV_LIT_REG: u16 = 0x01;
/// mov r1, r2; -> r1
pub const MOV_REG_REG: u16 = 0x02;
/// 'deref' pointer
/// ;r2 = 0xdeadbeef
/// ;0xdeadbeef = 'H'
/// mov r1, `[r2]`; r1 = 'H'
pub const MOV_ADDR_REG: u16 = 0x03;
/// 'deref' pointer and store at its addr
/// ```_
/// ;r1 = 'H'
/// ;r2 = 0xdeadbeef
/// ;0xdeadbeef = 0x0
/// mov [r2], r1
/// ;0xdeadbeef = 'H'```
pub const MOV_REG_ADDR: u16 = 0x04;
/// 'deref' pointer and store at its addr
/// ```_
/// ;r2 = 0xdeadbeef
/// ;0xdeadbeef = 0x0
/// mov [r2], 'H'
/// ;0xdeadbeef = 'H'```
pub const MOV_LIT_ADDR: u16 = 0x05;

/// load r1, 0xffff; -> r1
pub const LOAD: u16 = 0x06;
/// store 0xffff, 0xdead; -> 0xffff
pub const STORE_LIT: u16 = 0x07;
/// store 0xffff, r1; -> 0xffff
pub const STORE_REG: u16 = 0x08;

/// add 0xdead, 0xbeef; -> acc
pub const ADD_LIT_LIT: u16 = 0x09;
/// add r1, 0xdead; -> acc
pub const ADD_LIT_REG: u16 = 0x0a;
/// add r1, r2; -> acc
pub const ADD_REG_REG: u16 = 0x0b;

/// sub 0xdead, 0xbeef; -> acc
pub const SUB_LIT_LIT: u16 = 0x0c;
/// sub r1, 0xdead; -> acc
pub const SUB_LIT_REG: u16 = 0x0d;
/// sub r1, r2; -> acc
pub const SUB_REG_REG: u16 = 0x0e;

/// inc r1; -> r1 += 1
pub const INC_REG: u16 = 0x0f;
/// dec r1; -> r1 -= 1
pub const DEC_REG: u16 = 0xa0;

/// cmp 0xdead, 0xbeef; -> acc (0 eq, 1 ne)
pub const CMP_LIT_LIT: u16 = 0xb0;
/// cmp r1, 0xbeef; -> acc (0 eq, 1 ne)
pub const CMP_LIT_REG: u16 = 0xb1;
/// cmp r1, r2; -> acc (0 eq, 1 ne)
pub const CMP_REG_REG: u16 = 0xb2;

/// jmp 0x0000
pub const JMP: u16 = 0xb3;
/// cmp 0x00, 0x00
/// je 0xdead; -> 0xdead
pub const JE: u16 = 0xb4;
/// cmp 0x00, 0x00
/// jne 0xdead; -> continue
pub const JNE: u16 = 0xb5;

/// puti 0xff; -> 255
pub const PUT_INT_LIT: u16 = 0xdead;
/// puti r1
pub const PUT_INT_REG: u16 = 0xdeae;
/// putc 0x48; -> H
pub const PUT_CHAR_LIT: u16 = 0xbeef;
/// putc r1
pub const PUT_CHAR_REG: u16 = 0xbeff;

pub const HALT: u16 = 0xFFFF;
