const std = @import("std");

pub fn greet() void {
    std.debug.print("{s}\n", .{"Hello World!"});
}
