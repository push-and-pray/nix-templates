const std = @import("std");

const hello = @import("hello");

pub fn main(_: std.process.Init) !void {
    hello.greet();
}
