#include <std/mem.pat>
#include <std/string.pat>

u32 part_size @ 0x0;
struct header {
    u32 part_size; // Doesn't include padding at the end
    padding[4];
    u32 part_x;
    u32 part_y;
    padding[4];
    u8 visibility; // 01 = Hidden, 02 = Visible
    padding[1];
    u32 part_group_name_size;
    char part_group_name[part_group_name_size];
};

// Arc maybe (0x01)
struct sub_type_01 {
    u8 sub_type_identifier_01;
    u32 block_size;
    u32 layer; // Always 17 (silkscreen) so far    
    u32 x1;
    u32 y1;
    padding[block_size-12]; // Not rendered so not sure
};

// Line Segment (0x05)
struct sub_type_05 {
    u8 sub_type_identifier_05;
    u32 block_size;
    u32 layer; // Always 17 (silkscreen) so far
    u32 x1;
    u32 y1;
    u32 x2;
    u32 y2;
    u32 scale;
    padding[4];
};

// Labels/Part Names (0x06)
struct sub_type_06 {
    u8 sub_type_identifier_06;
    u32 block_size;
    u32 layer; // Always 17 (silkscreen) so far
    u32 x;
    u32 y;
    u32 font_size;
    u32 font_scale;
    padding[4];
    u8 visibility; // 01 = Hidden, 02 = Visible
    padding[1];
    u32 label_size;
    char label[label_size];
};

// Pins (0x09)
struct pin_sub_type_00 {
    u8 pin_net_identifier;
    u32 net_index;
    u32 diode_reading_size;
    char diode_reading[diode_reading_size];
};

struct pin_sub_type_01 {
    u8 pin_unknown_01_identifier;
    u32 int1;
    if (int1 > 0) {
        u32 int2;
    }
};

struct pin_sub_type_02 {
    u8 pin_unknown_02_identifier;
    u32 int1;
    if (int1 > 0) {
        u32 int2;
    }
};

struct pin_sub_types {
    if ($[$] == 0x00) {
        pin_sub_type_00 pin_sub_00;
    } else if ($[$] == 0x01) {
        pin_sub_type_01 pin_sub_01;
    } else if ($[$] == 0x02) {
        pin_sub_type_02 pin_sub_02;
    }
};

u32 block_end;
struct sub_type_09 {
    u8 sub_type_identifier_09;
    u32 block_size;
    block_end = $ + block_size;
    u32 un1; // Seen: 0,1
    u32 x;
    u32 y;
    u32 un2; // Seen: 0
    u32 pin_rotation; // Seen: 0,2700000
    u32 pin_name_size;
    char pin_name[pin_name_size];
    u32 height; // Don't know if radius or diameter (if circle) / from center or overall (if rectangle)
    u32 width; // ^^
    std::print(std::string::to_string(sizeof(this)));
    pin_sub_types sub_parts[while($ < block_end-4)];
    u32 un4; // Seen: 0
};

struct sub_blocks {
    if ($[$] == 0x01) {
        sub_type_01 arc_maybe;
    } else if ($[$] == 0x05) {
        sub_type_05 line_segment;
    } else if ($[$] == 0x06) {
        sub_type_06 labels;
    } else if ($[$] == 0x09) {
        sub_type_09 pins;
    } else {
        break;
    }
};

header header @ 0x0;
sub_blocks sub_blocks[while($ <= part_size)] @ $;
