/// An enum representing a Key.
/// Based on: https://source.chromium.org/chromium/chromium/src/+/main:ui/events/keycodes/dom/dom_code_data.inc
pub const Keycode = enum {
    // Non-USB codes
    hyper,
    super, // NOT Meta!
    @"fn",
    fn_lock,
    @"suspend",
    @"resume",
    turbo,

    // (Based on) USB Usage Page 0x01: Generic Desktop Page
    sleep,
    wake_up,
    mic_mute_toggle,
    disple_toggle_int_ext,

    // (Based on) USB Usage Page 0x07: Keyboard/Keypad Page
    // zig fmt: off
    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,
    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0",

    enter,
    escape,
    backspace,
    tab,
    space,
    minus,
    equal,
    bracket_left,
    bracket_right,
    backslash,
    semicolon,
    quote,
    backquote,
    comma,
    period,
    slash,
    caps_lock,

    f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14,
    f15, f16, f17, f18, f19, f20, f21, f22, f23, f24,
    sysrq, // = PrintScreen
    scroll_lock,
    pause,
    insert,
    home,
    page_up,
    delete,
    end,
    page_down,
    arrow_right,
    arrow_left,
    arrow_down,
    arrow_up,

    num_lock,
    numpad_divide,
    numpad_multiply,
    numpad_subtract,
    numpad_add,
    numpad_equal,
    numpad_decimal,
    numpad_comma,
    numpad_enter,
    numpad_backspace,
    numpad_1,
    numpad_2,
    numpad_3,
    numpad_4,
    numpad_5,
    numpad_6,
    numpad_7,
    numpad_8,
    numpad_9,
    numpad_0,

    intl_backslash, // = NonUSBackslash; Not present on US keyboards. Typically near left shift.
    international1, // = IntlRo
    international2, // = KanaMode
    international3, // = IntlYen
    international4, // = Convert
    international5, // = NonConvert
    international6,
    international7,
    international8,
    international9,
    lang1, lang2, lang3, lang4, lang5, lang6, lang7, lang8, lang9,

    context_menu,
    power,

    abort,
    open, // = Execute
    help,
    select,
    again,
    undo,
    cut,
    copy,
    paste,
    find,
    props,

    volume_mute,
    volume_up,
    volume_down,

    ctrl_left,
    shift_left,
    alt_left,
    ctrl_right,
    shift_right,
    alt_right,
    mode, // = AltGr
    // zig fmt: on

    // (Based on) USB Usage Page 0x0c: Consumer Page
    info,
    closed_caption_toggle,

    brightness_up,
    brightness_down,
    brightness_toggle,
    brightness_min,
    brightness_max,
    brightness_auto,

    kbd_backlight_up,
    kbd_backlight_down,
    kbd_backlight_toggle,

    launch_phone,
    launch_word_processor,
    launch_spreadsheet,
    launch_mail,
    launch_contacts,
    launch_calender,
    launch_task_manager,
    launch_log,
    launch_browser,
    launch_explorer, // = LaunchApp1; File Browser
    launch_calculator, // = LaunchApp2
    launch_control_panel,

    log_off,
    lock_screen,
    program_guide,
    exit,

    media_play,
    media_pause,
    media_playpause,
    media_stop,
    media_record,
    media_fast_forward,
    media_rewind,
    media_track_next,
    media_track_prev,
    media_last,
    media_select,
    eject,

    browser_search,
    browser_home,
    browser_back,
    browser_forward,
    browser_stop,
    browser_refresh,
};

/// Modifier keys which may be active at the time of a key event.
pub const Modifiers = struct {
    shift: bool = false,
    ctrl: bool = false,
    alt: bool = false,
    meta: bool = false,
    mode: bool = false, // = AltGr
};
