const std = @import("std");
const c = @cImport({
    @cInclude("clang-c/Index.h");
});
const CXCursorKind = @import("cxcursorkind.zig").CXCursorKind;

const Cursor = struct {
    cursor: c.CXCursor,
    parent_hash: u32,
};

const INDENT = [1]u8{' '} ** 200;
fn make_indent(level: usize) []const u8 {
    return INDENT[0 .. level * 2];
}

const Context = struct {
    allocator: std.mem.Allocator,
    cursor_map: std.AutoHashMap(u32, Cursor),

    fn init(allocator: std.mem.Allocator) @This() {
        const context = @This(){
            .allocator = allocator,
            .cursor_map = std.AutoHashMap(u32, Cursor).init(allocator),
        };
        return context;
    }

    fn deinit(self: *@This()) void {
        self.cursor_map.deinit();
    }

    fn push(self: *@This(), cursor: c.CXCursor, parent: c.CXCursor) bool {
        const kind: CXCursorKind = @enumFromInt(cursor.kind);

        const hash = c.clang_hashCursor(cursor);
        if (self.cursor_map.contains(hash)) {
            std.debug.print("already {}: {s}\n", .{hash, @tagName(kind)});
            return false;
        }
        const parent_hash = c.clang_hashCursor(parent);
        std.debug.assert(self.cursor_map.contains(parent_hash));
        // std.debug.print("{} => {}\n", .{hash, parent_hash});

        self.cursor_map.put(hash, .{
            .cursor = cursor,
            .parent_hash = parent_hash,
        }) catch @panic("put");

        const level = self.get_cursor_level(cursor);
        std.debug.print("{s}=>[{}]{s}\n", .{
            make_indent(level),
            level,
            @tagName(kind),
        });

        return true;
    }

    fn get_parent(self: @This(), cursor: c.CXCursor) ?c.CXCursor {
        const hash = c.clang_hashCursor(cursor);
        const ptr = self.cursor_map.getPtr(hash) orelse {
            return null;
        };
        const parent_ptr = self.cursor_map.getPtr(ptr.parent_hash) orelse {
            return null;
        };
        return parent_ptr.cursor;
    }

    fn get_cursor_level(self: @This(), cursor: c.CXCursor) usize {
        var level: usize = 0;
        var current = cursor;
        while (self.get_parent(current)) |parent| {
            level += 1;
            current = parent;
        }
        return level;
    }

    export fn visitor(cursor: c.CXCursor, parent: c.CXCursor, data: c.CXClientData) c.enum_CXChildVisitResult {
        const context: *Context = @ptrCast(@alignCast(data));

        if (context.push(cursor, parent)) {
            return c.CXChildVisit_Continue;
        } else {
            return c.CXChildVisit_Break;
        }
    }

    fn traverse(self: *@This(), tu: c.CXTranslationUnit) void {
        const root = c.clang_getTranslationUnitCursor(tu);
        const root_hash = c.clang_hashCursor(root);
        // std.debug.print("root_hash => {}\n", .{root_hash});
        self.cursor_map.put(root_hash, .{
            .cursor = root,
            .parent_hash = 0,
        }) catch @panic("put");
        _ = c.clang_visitChildren(root, visitor, self);
    }
};

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

    var context = Context.init(std.heap.page_allocator);
    context.traverse(tu);
}
