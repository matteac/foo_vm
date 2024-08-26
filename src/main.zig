const std = @import("std");
const instruction = @import("instruction.zig");
const register = @import("register.zig");
const vm = @import("vm.zig");

pub fn main() !void {
    const instr = [_]u16{
        // ptr
        instruction.MOV_LIT_REG,
        register.R2,
        0x12,

        // .loop_start

        // deref r2 and mov to r1
        instruction.MOV_ADDR_REG,
        register.R1,
        register.R2,

        instruction.CMP_LIT_REG,
        register.R1,
        0x0,

        // if r1 == null goto .loop_end
        instruction.JE,
        0x11,

        instruction.PUT_CHAR_REG,
        register.R1,

        // go to the next char
        instruction.INC_REG,
        register.R2,

        // goto .loop_start
        instruction.JMP,
        0x3,

        // .loop_end

        instruction.HALT,
        'H',
        'e',
        'l',
        'l',
        'o',
        ',',
        ' ',
        'W',
        'o',
        'r',
        'l',
        'd',
        '!',
        '\n',
        0,
    };
    var mem = [_]u16{0} ** 512;

    for (0.., instr) |i, op| {
        mem[i] = op;
    }

    var vmach = vm.VM.init(&mem);

    vmach.dump(instr.len);
    std.debug.print("\n", .{});
    while (true) {
        const status = try vmach.step();
        if (status >= 0) {
            vmach.dump_regs();
            std.process.exit(@intCast(status));
        }
    }
}
