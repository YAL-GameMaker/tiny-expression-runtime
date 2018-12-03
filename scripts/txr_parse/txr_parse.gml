var str = argument0;
var len = string_length(str);
var out = txr_parse_tokens;
ds_list_clear(out);
var pos = 1;
while (pos <= len) {
    var start = pos;
    var char = string_ord_at(str, pos);
    pos += 1;
    switch (char) {
        case ord(" "): case ord("\t"): case ord("\r"): case ord("\n"): break;
        case ord("("): ds_list_add(out, [txr_token.par_open, start]); break;
        case ord(")"): ds_list_add(out, [txr_token.par_close, start]); break;
        case ord("{"): ds_list_add(out, [txr_token.cub_open, start]); break;
        case ord("}"): ds_list_add(out, [txr_token.cub_close, start]); break;
        case ord(","): ds_list_add(out, [txr_token.comma, start]); break;
        case ord("+"): ds_list_add(out, [txr_token.op, start, txr_op.add]); break;
        case ord("-"): ds_list_add(out, [txr_token.op, start, txr_op.sub]); break;
        case ord("*"): ds_list_add(out, [txr_token.op, start, txr_op.mul]); break;
        case ord("/"): ds_list_add(out, [txr_token.op, start, txr_op.fdiv]); break;
        case ord("%"): ds_list_add(out, [txr_token.op, start, txr_op.fmod]); break;
        case ord("="): ds_list_add(out, [txr_token.set, start]); break;
        case ord("'"): case ord("\""): // ord('"') in GMS1
            while (pos <= len) {
                if (string_ord_at(str, pos) == char) break;
                pos += 1;
            }
            if (pos <= len) {
                pos += 1;
                ds_list_add(out, [txr_token._string, start,
                    string_copy(str, start + 1, pos - start - 2)]);
            } else return txr_throw("Unclosed string starting at", start);
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
                ds_list_add(out, [txr_token.number, start, val]);
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
                    case "mod": ds_list_add(out, [txr_token.op, start, txr_op.fmod]); break;
                    case "div": ds_list_add(out, [txr_token.op, start, txr_op.idiv]); break;
                    case "if": ds_list_add(out, [txr_token._if, start]); break;
                    case "else": ds_list_add(out, [txr_token._else, start]); break;
                    case "return": ds_list_add(out, [txr_token.ret, start]); break;
                    default: ds_list_add(out, [txr_token.ident, start, name]); break;
                }
            }
            else {
                ds_list_clear(out);
                return txr_throw("Unexpected character `" + chr(char) + "`", start);
            }
    }
}
ds_list_add(out, [txr_token.eof, string_length(str)]);
return false;