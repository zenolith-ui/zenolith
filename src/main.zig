const std = @import("std");

const root = @import("root");

/// A zenolith-scoped logger for internal use.
pub const log = std.log.scoped(.zenolith);

test {
    _ = attreebute;
    _ = backevent;
    _ = key;
    _ = layout;
    _ = painter;
    _ = platform;
    _ = text;
    _ = texture;
    _ = treevent;
    _ = util;
    _ = widget;

    _ = Color;
    _ = WidgetIter;
}

pub const attreebute = @import("attreebute.zig");
pub const backevent = @import("backevent.zig");
pub const key = @import("key.zig");
pub const layout = @import("layout.zig");
pub const painter = @import("painter.zig");
pub const platform = @import("platform.zig");
pub const text = @import("text.zig");
pub const texture = @import("texture.zig");
pub const treevent = @import("treevent.zig");
pub const util = @import("util.zig");
pub const widget = @import("widget.zig");

pub const Color = @import("Color.zig");
pub const WidgetIter = @import("WidgetIter.zig");

/// List of the default widget implementations included with Zenolith.
/// If you set zenolith_options.widget_impls, include this if you want to use Zenolith's widgets.
pub const default_widget_impls = [_]type{
    widget.Box,
    widget.Button,
    widget.ChunkView,
    widget.Label,
    widget.Spacer,
};

/// The default painter implementations bundled with Zenolith.
pub const default_painter_impls = [_]type{};

/// The default platform implementations included with Zenolith. This is likely to remain empty.
pub const default_platform_impls = [_]type{};

/// The default backevents in Zenolith. Remember that these may be required by widgets.
pub const default_backevents = [_]type{
    backevent.ButtonActivated,
};

const root_options = if (@hasDecl(root, "zenolith_options")) root.zenolith_options else struct {};

comptime {
    const backevent_info = @typeInfo(@TypeOf(backevents));
    if (backevent_info != .Array or backevent_info.Array.child != type)
        @compileError("backevents must be a [_]type!");

    const widget_impl_info = @typeInfo(@TypeOf(widget_impls));
    if (widget_impl_info != .Array or widget_impl_info.Array.child != type)
        @compileError("widget_impls must be a [_]type!");

    const painter_impl_info = @typeInfo(@TypeOf(painter_impls));
    if (painter_impl_info != .Array or painter_impl_info.Array.child != type)
        @compileError("painter_impls must be a [_]type!");

    const platform_impl_info = @typeInfo(@TypeOf(platform_impls));
    if (platform_impl_info != .Array or platform_impl_info.Array.child != type)
        @compileError("platform_impls must be a [_]type!");
}

pub const backevents = if (@hasDecl(root_options, "backevents"))
    root_options.backevents
else
    default_backevents;

pub const widget_impls = if (@hasDecl(root_options, "widget_impls"))
    root_options.widget_impls
else
    default_widget_impls;

pub const painter_impls = if (@hasDecl(root_options, "painter_impls"))
    root_options.painter_impls
else
    default_painter_impls;

pub const platform_impls = if (@hasDecl(root_options, "platform_impls"))
    root_options.platform_impls
else
    default_platform_impls;

/// Set this to true to draw debugging information such as various bounding boxes.
pub const debug_render: bool = if (@hasDecl(root_options, "debug_render"))
    root_options.debug_render
else
    false;
