const std = @import("std");
const c = @import("c.zig");
const Context = @import("Context.zig");

// std.os.argv
// 0: self
// 1: src
// 2: dst
pub fn main() !void {
    const src = std.mem.span(std.os.argv[1]);
    const dst = std.mem.span(std.os.argv[2]);
    std.debug.print("write to {s}\n", .{dst});
    const file = try std.fs.cwd().createFile(
        dst,
        .{},
    );
    defer file.close();
    const writer = file.writer();
    try writer.print("pub const X:i32=0;\n", .{});

    // parse
    const index = c.clang_createIndex(1, 0);
    defer c.clang_disposeIndex(index);
    const tu = c.clang_parseTranslationUnit(
        index,
        src,
        null,
        0,
        null,
        0,
        c.CXTranslationUnit_DetailedPreprocessingRecord | c.CXTranslationUnit_SkipFunctionBodies,
    );
    defer c.clang_disposeTranslationUnit(tu);

    // traverse
    var context = Context.init(std.heap.page_allocator);
    defer context.deinit();
    context.traverse(tu);
}
