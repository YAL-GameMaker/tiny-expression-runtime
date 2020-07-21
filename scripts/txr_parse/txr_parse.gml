var str = argument0;
var len = string_length(str);
var out = txr_parse_tokens;
ds_list_clear(out);
var pos = 1;
var line_start = 1;
var line_number = 0;
while (pos <= len) {
    var start = pos;
    var inf = line_number * 32000 + clamp(pos - line_start, 0, 31999);
    var char = string_ord_at(str, pos);
    pos += 1;
    switch (char) {
        case ord(" "): case ord("\t"): case ord("\r"): break;
        case ord("\n"): line_number++; line_start = pos; break;
        case ord(";"): ds_list_add(out, [txr_token.semico, inf]); break;
        case ord(":"): ds_list_add(out, [txr_token.colon, inf]); break;
        case ord("("): ds_list_add(out, [txr_token.par_open, inf]); break;
        case ord(")"): ds_list_add(out, [txr_token.par_close, inf]); break;
        case ord("{"): ds_list_add(out, [txr_token.cub_open, inf]); break;
        case ord("}"): ds_list_add(out, [txr_token.cub_close, inf]); break;
        case ord(","): ds_list_add(out, [txr_token.comma, inf]); break;
        case ord("."): ds_list_add(out, [txr_token.period, inf]); break;
        case ord("+"):
            switch (string_ord_at(str, pos)) {
                case ord("="): // +=
                    pos += 1;
                    ds_list_add(out, [txr_token.set, inf, txr_op.add]);
                    break;
                case ord("+"): // ++
                    pos += 1;
                    ds_list_add(out, [txr_token.adjfix, inf, 1]);
                    break;
                default:
                   ds_list_add(out, [txr_token.op, inf, txr_op.add]);
            }
            break;
        case ord("-"):
            switch (string_ord_at(str, pos)) {
                case ord("="): // -=
                    pos += 1;
                    ds_list_add(out, [txr_token.set, inf, txr_op.sub]);
                    break;
                case ord("-"): // --
                    pos += 1;
                    ds_list_add(out, [txr_token.adjfix, inf, -1]);
                    break;
                default:
                   ds_list_add(out, [txr_token.op, inf, txr_op.sub]);
            }
            break;
        case ord("*"):
            if (string_ord_at(str, pos) == ord("=")) { // *=
                pos += 1;
                ds_list_add(out, [txr_token.set, inf, txr_op.mul]);
            } else ds_list_add(out, [txr_token.op, inf, txr_op.mul]);
            break;
        case ord("/"):
            switch (string_ord_at(str, pos)) {
                case ord("="): // /=
                    pos += 1;
                    ds_list_add(out, [txr_token.set, inf, txr_op.fdiv]);
                    break;
                case ord("/"): // line comment
                    while (pos <= len) {
                        char = string_ord_at(str, pos);
                        if (char == ord("\r") || char == ord("\n")) break;
                        pos += 1;
                    }
                    break;
                case ord("*"): // block comment
                    pos += 1;
                    while (pos <= len) {
                        if (string_ord_at(str, pos) == ord("*")
                        && string_ord_at(str, pos + 1) == ord("/")) {
                            pos += 2;
                            break;
                        }
                        pos += 1;
                    }
                    break;
                default: ds_list_add(out, [txr_token.op, inf, txr_op.fdiv]);
            }
            break;
        case ord("%"):
            if (string_ord_at(str, pos) == ord("=")) { // %=
                pos += 1;
                ds_list_add(out, [txr_token.set, inf, txr_op.fmod]);
            } else ds_list_add(out, [txr_token.op, inf, txr_op.fmod]);
            break;
        case ord("!"):
            if (string_ord_at(str, pos) == ord("=")) { // !=
                pos += 1;
                ds_list_add(out, [txr_token.op, inf, txr_op.ne]);
            } else ds_list_add(out, [txr_token.unop, inf, txr_unop.invert]);
            break;
        case ord("="):
            if (string_ord_at(str, pos) == ord("=")) { // ==
                pos += 1;
                ds_list_add(out, [txr_token.op, inf, txr_op.eq]);
            } else ds_list_add(out, [txr_token.set, inf, txr_op.set]);
            break;
        case ord("<"):
            switch (string_ord_at(str, pos)) {
                case ord("="): // <=
                    pos += 1;
                    ds_list_add(out, [txr_token.op, inf, txr_op.le]);
                    break;
                case ord("<"): // <<
                    pos += 1;
                    ds_list_add(out, [txr_token.op, inf, txr_op.shl]);
                    break;
                default:
                    ds_list_add(out, [txr_token.op, inf, txr_op.lt]);
            }
            break;
        case ord(">"):
            switch (string_ord_at(str, pos)) {
                case ord("="): // >=
                    pos += 1;
                    ds_list_add(out, [txr_token.op, inf, txr_op.ge]);
                    break;
                case ord(">"): // >>
                    pos += 1;
                    ds_list_add(out, [txr_token.op, inf, txr_op.shr]);
                    break;
                default:
                    ds_list_add(out, [txr_token.op, inf, txr_op.gt]);
            }
            break;
        case ord("'"): case ord("\""): // ord('"') in GMS1
            while (pos <= len) {
                if (string_ord_at(str, pos) == char) break;
                pos += 1;
            }
            if (pos <= len) {
                pos += 1;
                ds_list_add(out, [txr_token._string, inf,
                    string_copy(str, start + 1, pos - start - 2)]);
            } else return txr_throw("Unclosed string starting", txr_print_pos(inf));
            break;
        case ord("|"):
            switch (string_ord_at(str, pos)) {
                case ord("|"): // ||
                    pos += 1;
                    ds_list_add(out, [txr_token.op, inf, txr_op.bor]);
                    break;
                case ord("="): // |=
                    pos += 1;
                    ds_list_add(out, [txr_token.set, inf, txr_op.ior]);
                    break;
                default:
                    ds_list_add(out, [txr_token.op, inf, txr_op.ior]);
            }
            break;
        case ord("&"):
            switch (string_ord_at(str, pos)) {
                case ord("&"): // &&
                    pos += 1;
                    ds_list_add(out, [txr_token.op, inf, txr_op.band]);
                    break;
                case ord("="): // &=
                    pos += 1;
                    ds_list_add(out, [txr_token.set, inf, txr_op.iand]);
                    break;
                default:
                    ds_list_add(out, [txr_token.op, inf, txr_op.iand]);
            }
            break;
        case ord("^"):
            if (string_ord_at(str, pos) == ord("=")) { // ^=
                pos += 1;
                ds_list_add(out, [txr_token.set, inf, txr_op.ixor]);
            } else ds_list_add(out, [txr_token.op, inf, txr_op.ixor]);
            break;
        default:
            if (char >= ord("0") && char <= ord("9")) {
                var pre_dot = true;
                while (pos <= len) {
                    char = string_ord_at(str, pos);
                    if (char == ord(".")) {
                        if (pre_dot) {
                            pre_dot = false;
                            pos += 1;
                        } else break;
                    } else if (char >= ord("0") && char <= ord("9")) {
                        pos += 1;
                    } else break;
                }
                var val = real(string_copy(str, start, pos - start));
                ds_list_add(out, [txr_token.number, inf, val]);
            }
            else if (char == ord("_")
                || (char >= ord("a") && char <= ord("z"))
                || (char >= ord("A") && char <= ord("Z"))
            ) {
                while (pos <= len) {
                    char = string_ord_at(str, pos);
                    if (char == ord("_")
                        || (char >= ord("0") && char <= ord("9"))
                        || (char >= ord("a") && char <= ord("z"))
                        || (char >= ord("A") && char <= ord("Z"))
                    ) {
                        pos += 1;
                    } else break;
                }
                var name = string_copy(str, start, pos - start);
                switch (name) {
                    case "true": ds_list_add(out, [txr_token.number, inf,true]); break;
                    case "false": ds_list_add(out, [txr_token.number, inf,false]); break;
                    case "mod": ds_list_add(out, [txr_token.op, inf, txr_op.fmod]); break;
                    case "div": ds_list_add(out, [txr_token.op, inf, txr_op.idiv]); break;
                    case "if": ds_list_add(out, [txr_token._if, inf]); break;
                    case "else": ds_list_add(out, [txr_token._else, inf]); break;
                    case "return": ds_list_add(out, [txr_token.ret, inf]); break;
                    case "while": ds_list_add(out, [txr_token._while, inf]); break;
                    case "do": ds_list_add(out, [txr_token._do, inf]); break;
                    case "for": ds_list_add(out, [txr_token._for, inf]); break;
                    case "break": ds_list_add(out, [txr_token._break, inf]); break;
                    case "continue": ds_list_add(out, [txr_token._continue, inf]); break;
                    case "var": ds_list_add(out, [txr_token._var, inf]); break;
                    case "argument_count": ds_list_add(out, [txr_token._argument_count, inf]); break;
                    case "label": ds_list_add(out, [txr_token.label, inf]); break;
                    case "jump": ds_list_add(out, [txr_token.jump, inf]); break;
                    case "call": ds_list_add(out, [txr_token.jump_push, inf]); break;
                    case "back": ds_list_add(out, [txr_token.jump_pop, inf]); break;
                    case "select": ds_list_add(out, [txr_token._select, inf]); break;
                    case "option": ds_list_add(out, [txr_token._option, inf]); break;
                    case "default": ds_list_add(out, [txr_token._default, inf]); break;
                    case "switch": ds_list_add(out, [txr_token._switch, inf]); break;
                    case "case": ds_list_add(out, [txr_token._case, inf]); break;
                    default:
                        if (string_length(name) > 8 && string_copy(name, 1, 8) == "argument") {
                            var sfx = string_delete(name, 1, 8); // substring(8) in non-GML
                            if (string_digits(sfx) == sfx) {
                                ds_list_add(out, [txr_token._argument, inf, real(sfx), name]);
                                break;
                            }
                        }
                        ds_list_add(out, [txr_token.ident, inf, name]);
                        break;
                }
            }
            else {
                ds_list_clear(out);
                return txr_throw("Unexpected character `" + chr(char) + "`", txr_print_pos(inf));
            }
    }
}
ds_list_add(out, [txr_token.eof, string_length(str)]);
return false;