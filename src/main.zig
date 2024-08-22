const std = @import("std");
const instruction = @import("instruction.zig");
const register = @import("register.zig");
const vm = @import("vm.zig");

pub fn main() !void {
    const instr = [_]u16{
        instruction.LOAD,
        register.R1,
        0x0000,
        instruction.HALT,
    };
    var mem = [_]u16{0} ** 512;

    for (0.., instr) |i, op| {
        mem[i] = op;
    }

    var vmach = vm.VM.init(&mem);

    vmach.dump(instr.len + 1);
    while (true) {
        const status = try vmach.step();
        if (status >= 0) {
            std.process.exit(@intCast(status));
        }
        vmach.dump_regs();
    }
}
