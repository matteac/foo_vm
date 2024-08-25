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
        var vm = VM{ .memory = mem };

        vm.memory[vm.memory.len - 1] = instruction.HALT;
        return vm;
    }

    pub fn step(self: *VM) !i16 {
        switch (try self.fetch()) {
            instruction.MOV_LIT_REG => {
                const reg = try self.fetch();
                const val = try self.fetch();
                // std.debug.print("\nSetting register 0x{x} to 0x{x}\n\n", .{ reg, val });
                self.reg[reg] = val;
            },
            instruction.MOV_REG_REG => {
                const rega = try self.fetch();
                const regb = try self.fetch();
                self.reg[rega] = self.reg[regb];
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

            instruction.NOP => {},
            instruction.HALT => return 0,
            else => return VMError.InvalidInstruction,
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
