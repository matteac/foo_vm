const std = @import("std");
const register = @import("register.zig");
const instruction = @import("instruction.zig");

pub const VMError = error{
    InvalidInstruction,
    OutOfBounds,
};

pub const VM = struct {
    /// IP ACC R1 R2
    reg: [4]u16 = [_]u16{ 0, 0, 0, 0 },
    memory: []u16,

    pub fn init(mem: []u16) VM {
        return VM{ .memory = mem };
    }

    pub fn step(self: *VM) !i16 {
        const op = try self.fetch();
        switch (op) {
            instruction.MOV_LIT_REG => {
                const reg = try self.fetch();
                const val = try self.fetch();
                self.reg[reg] = val;
            },
            instruction.MOV_REG_REG => {
                const rega = try self.fetch();
                const regb = try self.fetch();
                self.reg[rega] = self.reg[regb];
            },
            instruction.MOV_ADDR_REG => {
                const rega = try self.fetch();
                const regb = try self.fetch();
                const addr = self.reg[regb];
                if (addr >= self.memory.len) {
                    return VMError.OutOfBounds;
                }
                const val = self.memory[addr];
                self.reg[rega] = val;
            },
            instruction.MOV_REG_ADDR => {
                const rega = try self.fetch();
                const regb = try self.fetch();
                const addr = self.reg[rega];
                const val = self.reg[regb];
                if (addr >= self.memory.len) return VMError.OutOfBounds;
                self.memory[addr] = val;
            },
            instruction.MOV_LIT_ADDR => {
                const reg = try self.fetch();
                const val = try self.fetch();
                const addr = self.reg[reg];
                if (addr >= self.memory.len) return VMError.OutOfBounds;
                self.memory[addr] = val;
            },

            instruction.LOAD => {
                const reg = try self.fetch();
                const addr = try self.fetch();
                if (addr >= self.memory.len) {
                    return VMError.OutOfBounds;
                }
                self.reg[reg] = self.memory[addr];
            },
            instruction.STORE_LIT => {
                const addr = try self.fetch();
                const val = try self.fetch();
                if (addr >= self.memory.len) {
                    return VMError.OutOfBounds;
                }
                self.memory[addr] = val;
            },
            instruction.STORE_REG => {
                const addr = try self.fetch();
                const reg = try self.fetch();
                if (addr >= self.memory.len) {
                    return VMError.OutOfBounds;
                }
                self.memory[addr] = self.reg[reg];
            },

            instruction.ADD_LIT_LIT => {
                const vala = try self.fetch();
                const valb = try self.fetch();
                self.reg[register.ACC] = vala + valb;
            },
            instruction.ADD_LIT_REG => {
                const reg = try self.fetch();
                const vala = self.reg[reg];
                const valb = try self.fetch();
                self.reg[register.ACC] = vala + valb;
            },
            instruction.ADD_REG_REG => {
                const rega = try self.fetch();
                const regb = try self.fetch();
                const vala = self.reg[rega];
                const valb = self.reg[regb];
                self.reg[register.ACC] = vala + valb;
            },

            instruction.SUB_LIT_LIT => {
                const vala = try self.fetch();
                const valb = try self.fetch();
                self.reg[register.ACC] = vala - valb;
            },
            instruction.SUB_LIT_REG => {
                const reg = try self.fetch();
                const vala = self.reg[reg];
                const valb = try self.fetch();
                self.reg[register.ACC] = vala - valb;
            },
            instruction.SUB_REG_REG => {
                const rega = try self.fetch();
                const regb = try self.fetch();
                const vala = self.reg[rega];
                const valb = self.reg[regb];
                self.reg[register.ACC] = vala - valb;
            },
            instruction.INC_REG => {
                const reg = try self.fetch();
                self.reg[reg] += 1;
            },

            instruction.DEC_REG => {
                const reg = try self.fetch();
                self.reg[reg] -= 1;
            },

            instruction.CMP_LIT_LIT => {
                const vala = try self.fetch();
                const valb = try self.fetch();
                if (vala == valb) {
                    self.reg[register.ACC] = 0;
                } else {
                    self.reg[register.ACC] = 1;
                }
            },
            instruction.CMP_LIT_REG => {
                const reg = try self.fetch();
                const vala = self.reg[reg];
                const valb = try self.fetch();
                if (vala == valb) {
                    self.reg[register.ACC] = 0;
                } else {
                    self.reg[register.ACC] = 1;
                }
            },
            instruction.CMP_REG_REG => {
                const rega = try self.fetch();
                const vala = self.reg[rega];
                const regb = try self.fetch();
                const valb = self.reg[regb];
                if (vala == valb) {
                    self.reg[register.ACC] = 0;
                } else {
                    self.reg[register.ACC] = 1;
                }
            },

            instruction.JMP => {
                const addr = try self.fetch();
                self.reg[register.IP] = addr;
            },
            instruction.JE => {
                const addr = try self.fetch();
                if (self.reg[register.ACC] == 0) {
                    self.reg[register.IP] = addr;
                }
            },
            instruction.JNE => {
                const addr = try self.fetch();
                if (self.reg[register.ACC] == 1) {
                    self.reg[register.IP] = addr;
                }
            },

            instruction.PUT_INT_LIT => {
                const val = try self.fetch();
                try self.put_int(val);
            },
            instruction.PUT_INT_REG => {
                const reg = try self.fetch();
                const val = self.reg[reg];
                try self.put_int(val);
            },

            instruction.PUT_CHAR_LIT => {
                const val = try self.fetch();
                try self.put_char(@intCast(val));
            },
            instruction.PUT_CHAR_REG => {
                const reg = try self.fetch();
                const val = self.reg[reg];
                try self.put_char(@intCast(val));
            },

            instruction.NOP => {},
            instruction.HALT => return 0,
            else => {
                std.debug.print("INVALID: {x}\n", .{op});
                return VMError.InvalidInstruction;
            },
        }
        return -1;
    }

    fn put_int(_: *VM, val: u16) !void {
        const stdout = std.io.getStdOut().writer();
        try std.fmt.format(stdout, "{}", .{val});
    }
    fn put_char(_: *VM, ch: u8) !void {
        const stdout = std.io.getStdOut().writer();
        try std.fmt.format(stdout, "{s}", .{[_]u8{ch}});
    }

    fn fetch(self: *VM) !u16 {
        if (self.reg[register.IP] >= self.memory.len) {
            return VMError.OutOfBounds;
        }
        const data = self.memory[self.reg[register.IP]];
        self.reg[register.IP] += 1;
        return data;
    }

    pub fn dump(self: *VM, words: u16) void {
        std.debug.print("\x1b[32mADDR\tVAL\n\x1b[0m", .{});
        for (0..words) |i| {
            std.debug.print("0x{x}\t0x{x}\n", .{ i, self.memory[i] });
        }
    }

    pub fn dump_regs(self: *VM) void {
        std.debug.print("\x1b[32mREG\tVAL\n\x1b[0m", .{});
        for (0..self.reg.len) |i| {
            std.debug.print("0x{x}\t0x{x}\n", .{ i, self.reg[i] });
        }
    }
};

test "mov_lit_reg" {
    var instructions = [_]u16{
        instruction.MOV_LIT_REG,
        register.R1,
        0xdead,
        instruction.HALT,
    };
    var vm = VM.init(&instructions);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.reg[register.R1] == 0xdead);
            return;
        }
    }
}

test "mov_reg_reg" {
    var instructions = [_]u16{
        instruction.MOV_LIT_REG,
        register.R1,
        0xdead,
        instruction.MOV_REG_REG,
        register.R2,
        register.R1,
        instruction.HALT,
    };
    var vm = VM.init(&instructions);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.reg[register.R1] == 0xdead);
            try std.testing.expect(vm.reg[register.R2] == 0xdead);
            return;
        }
    }
}

test "mov_addr_reg" {
    var instructions = [_]u16{
        instruction.MOV_LIT_REG,
        register.R2,
        0x7,
        instruction.MOV_ADDR_REG,
        register.R1,
        register.R2,
        instruction.HALT,
        'H',
    };
    var vm = VM.init(&instructions);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.reg[register.R1] == 'H');
            try std.testing.expect(vm.reg[register.R2] == 0x7);
            return;
        }
    }
}

test "mov_reg_addr" {
    var instructions = [_]u16{
        instruction.MOV_LIT_REG,
        register.R1,
        0xa,
        instruction.MOV_LIT_REG,
        register.R2,
        'H',
        instruction.MOV_REG_ADDR,
        register.R1,
        register.R2,
        instruction.HALT,
        0x0,
    };
    var vm = VM.init(&instructions);
    try std.testing.expect(vm.memory[0xa] == 0x0);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.reg[register.R1] == 0xa);
            try std.testing.expect(vm.reg[register.R2] == 'H');
            try std.testing.expect(vm.memory[0xa] == 'H');
            return;
        }
    }
}
test "mov_lit_addr" {
    var instructions = [_]u16{
        instruction.MOV_LIT_REG,
        register.R1,
        0x7,
        instruction.MOV_LIT_ADDR,
        register.R1,
        'H',
        instruction.HALT,
        0x0,
    };
    var vm = VM.init(&instructions);
    try std.testing.expect(vm.memory[0x7] == 0x0);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.reg[register.R1] == 0x7);
            try std.testing.expect(vm.memory[0x7] == 'H');
            return;
        }
    }
}

test "load" {
    var instructions = [_]u16{
        instruction.LOAD,
        register.R1,
        0x4,
        instruction.HALT,
        0xdead,
    };
    var vm = VM.init(&instructions);
    try std.testing.expect(vm.memory[0x4] == 0xdead);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.reg[register.R1] == 0xdead);
            try std.testing.expect(vm.memory[0x4] == 0xdead);
            return;
        }
    }
}

test "store_lit" {
    var instructions = [_]u16{
        instruction.STORE_LIT,
        0x4,
        0xdead,
        instruction.HALT,
        0x0,
    };
    var vm = VM.init(&instructions);
    try std.testing.expect(vm.memory[0x4] == 0x0);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.memory[0x4] == 0xdead);
            return;
        }
    }
}

test "store_reg" {
    var instructions = [_]u16{
        instruction.MOV_LIT_REG,
        register.R1,
        0xdead,
        instruction.STORE_REG,
        0x7,
        register.R1,
        instruction.HALT,
        0x0,
    };
    var vm = VM.init(&instructions);
    try std.testing.expect(vm.memory[0x7] == 0x0);
    while (true) {
        const status = try vm.step();
        if (status >= 0) {
            try std.testing.expect(status == 0);
            try std.testing.expect(vm.memory[0x7] == 0xdead);
            return;
        }
    }
}
