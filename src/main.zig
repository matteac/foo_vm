const std = @import("std");
const instruction = @import("instruction.zig");
const register = @import("register.zig");
const vm = @import("vm.zig");
const lexer = @import("compiler/lexer.zig");

pub fn main() !void {
    const instr = [_]u16{
        instruction.MOV_LIT_REG,
        register.R1,
        0x0,

        // .loop_start

        instruction.CMP_LIT_REG,
        register.R1,
        0xffff,

        // if r1 == 0xffff goto .loop_end
        instruction.JE,
        12,

        instruction.INC_REG,
        register.R1,

        // goto .loop_start
        instruction.JMP,
        3,

        // .loop_end

        instruction.PUT_INT_REG,
        register.R1,

        instruction.PUT_CHAR_LIT,
        '\n',

        instruction.HALT,
    };
    var mem = [_]u16{0} ** 512;

    for (0.., instr) |i, op| {
        mem[i] = op;
    }

    var vmach = vm.VM.init(&mem);

    vmach.dump(instr.len + 1);
    std.debug.print("\n", .{});
    while (true) {
        const status = try vmach.step();
        if (status >= 0) {
            vmach.dump_regs();
            std.process.exit(@intCast(status));
        }
    }
}
