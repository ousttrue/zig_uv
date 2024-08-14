const std = @import("std");
const c = @cImport({
    @cInclude("clang-c/Index.h");
});
const CXCursorKind = @import("cxcursorkind.zig").CXCursorKind;

const Context = struct {
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) @This() {
        const context = @This(){
            .allocator = allocator,
        };
        return context;
    }

    fn deinit(self: *@This()) void {
        _ = self;
    }

    fn push(_: *@This(), cursor: c.CXCursor, parent: c.CXCursor) bool {
        const kind: CXCursorKind = @enumFromInt(cursor.kind);
        const parent_kind: CXCursorKind = @enumFromInt(parent.kind);
        std.debug.print("{s}({s})\n", .{
            @tagName(kind),
            @tagName(parent_kind),
        });
        return false;
    }
};

export fn visitor(cursor: c.CXCursor, parent: c.CXCursor, data: c.CXClientData) c.enum_CXChildVisitResult {
    const context: *Context = @ptrCast(@alignCast(data));

    if (context.push(cursor, parent)) {
        return c.CXChildVisit_Continue;
    } else {
        return c.CXChildVisit_Break;
    }
}

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

    const index = c.clang_createIndex(1, 0);

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

    const root = c.clang_getTranslationUnitCursor(tu);

    var context = Context.init(std.heap.page_allocator);
    _ = c.clang_visitChildren(root, visitor, &context);
}
