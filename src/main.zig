const std = @import("std");
const instruction = @import("instruction.zig");
const register = @import("register.zig");
const vm = @import("vm.zig");

pub fn main() !void {
    const instr = [_]u16{
        instruction.PUT_CHAR_LIT,
        0x48,
        instruction.PUT_CHAR_LIT,
        0x65,
        instruction.PUT_CHAR_LIT,
        0x6c,
        instruction.PUT_CHAR_LIT,
        0x6c,
        instruction.PUT_CHAR_LIT,
        0x6f,
        instruction.PUT_CHAR_LIT,
        0x2c,
        instruction.PUT_CHAR_LIT,
        0x20,
        instruction.PUT_CHAR_LIT,
        0x57,
        instruction.PUT_CHAR_LIT,
        0x6f,
        instruction.PUT_CHAR_LIT,
        0x72,
        instruction.PUT_CHAR_LIT,
        0x6c,
        instruction.PUT_CHAR_LIT,
        0x64,
        instruction.PUT_CHAR_LIT,
        0x21,
        instruction.PUT_CHAR_LIT,
        0xa,
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
            std.process.exit(@intCast(status));
        }
        // vmach.dump_regs();
    }
}
