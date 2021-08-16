/// @param flags
function txr_build_expr(argument0) {
	var flags = argument0;
	var tk = txr_build_list[|txr_build_pos++];
	switch (tk[0]) {
		case txr_token.number: txr_build_node = [txr_node.number, tk[1], tk[2]]; break;
		case txr_token._string: txr_build_node = [txr_node._string, tk[1], tk[2]]; break;
		case txr_token.ident:
			var tkn = txr_build_list[|txr_build_pos];
			if (tkn[0] == txr_token.par_open) { // `ident(`
				txr_build_pos += 1;
				// look up the function
				var args = [], argc = 0;
				var fn = global.txr_function_map[?tk[2]];
				var fn_script, fn_argc;
				if (fn == undefined) {
					fn_script = txr_function_default;
					if (fn_script != -1) {
						fn_argc = -1;
						args[argc++] = [txr_node._string, tk[1], tk[2]];
					} else return txr_throw_at("Unknown function `" + tk[2] + "`", tk);
				} else {
					fn_script = fn[0];
					fn_argc = fn[1];
				}
				// read the arguments and the closing `)`:
				var closed = false;
				while (txr_build_pos < txr_build_len) {
					// hit a closing `)` yet?
					tkn = txr_build_list[|txr_build_pos];
					if (tkn[0] == txr_token.par_close) {
						txr_build_pos += 1;
						closed = true;
						break;
					}
					// read the argument:
					if (txr_build_expr(0)) return true;
					args[argc++] = txr_build_node;
					// skip a `,`:
					tkn = txr_build_list[|txr_build_pos];
					if (tkn[0] == txr_token.comma) {
						txr_build_pos += 1;
					} else if (tkn[0] != txr_token.par_close) {
						return txr_throw_at("Expected a `,` or `)`", tkn);
					}
				}
				if (!closed) return txr_throw_at("Unclosed `()` after", tk);
				// find the function, verify argument count, and finally pack up:
				if (fn_argc >= 0 && argc != fn_argc) return txr_throw_at("`" + tk[2] + "` takes "
					+ string(fn_argc) + " argument(s), got " + string(argc), tk);
				txr_build_node = [txr_node.call, tk[1], fn_script, args, fn_argc];
			} else txr_build_node = [txr_node.ident, tk[1], tk[2]];
			break;
		case txr_token._argument: txr_build_node = [txr_node._argument, tk[1], tk[2], tk[3]]; break;
		case txr_token._argument_count: txr_build_node = [txr_node._argument_count, tk[1]]; break;
		case txr_token.par_open: // (value)
			if (txr_build_expr(0)) return true;
			tk = txr_build_list[|txr_build_pos++];
			if (tk[0] != txr_token.par_close) return txr_throw_at("Expected a `)`", tk);
			break;
		case txr_token.op: // -value, +value
			switch (tk[2]) {
				case txr_op.add:
					if (txr_build_expr(txr_build_flag.no_ops)) return true;
					break;
				case txr_op.sub:
					if (txr_build_expr(txr_build_flag.no_ops)) return true;
					txr_build_node = [txr_node.unop, tk[1], txr_unop.negate, txr_build_node];
					break;
				default: return txr_throw_at("Expected an expression", tk);
			}
			break;
		case txr_token.unop: // !value
			if (txr_build_expr(txr_build_flag.no_ops)) return true;
			txr_build_node = [txr_node.unop, tk[1], tk[2], txr_build_node];
			break;
		case txr_token.adjfix: // ++value
			if (txr_build_expr(txr_build_flag.no_ops)) return true;
			txr_build_node = [txr_node.prefix, tk[1], txr_build_node, tk[2]];
			break;
		case txr_token.sqb_open: // [...values]
			var closed = false;
			var args = [], argc = 0;
			while (txr_build_pos < txr_build_len) {
				// hit a closing `]` yet?
				tkn = txr_build_list[|txr_build_pos];
				if (tkn[0] == txr_token.sqb_close) {
					txr_build_pos += 1;
					closed = true;
					break;
				}
				// read the value:
				if (txr_build_expr(0)) return true;
				args[argc++] = txr_build_node;
				// skip a `,`:
				tkn = txr_build_list[|txr_build_pos];
				if (tkn[0] == txr_token.comma) {
					txr_build_pos += 1;
				} else if (tkn[0] != txr_token.sqb_close) {
					return txr_throw_at("Expected a `,` or `]`", tkn);
				}
			}
			if (!closed) return txr_throw_at("Unclosed `[]` after", tk);
			txr_build_node = [txr_node.array_literal, tk[1], args];
			break;
		default: return txr_throw_at("Expected an expression", tk);
	}

	// handle postfixes after expression
	while (txr_build_pos < txr_build_len) {
		tk = txr_build_list[|txr_build_pos];
		var _break = false;
		switch (tk[0]) {
			case txr_token.period: // value.field?
				if ((flags & txr_build_flag.no_suffix) == 0) {
					txr_build_pos += 1;
					tk = txr_build_list[|txr_build_pos];
					if (tk[0] != txr_token.ident) return txr_throw_at("Expected a field name", tk);
					txr_build_pos += 1;
					txr_build_node = [txr_node.field, tk[1], txr_build_node, tk[2]];
				} else return txr_throw_at("Unexpected `.`", tk);
				break;
			case txr_token.sqb_open: // value[index]?
				if ((flags & txr_build_flag.no_suffix) == 0) {
					txr_build_pos += 1;
					var node = txr_build_node;
					if (txr_build_expr(txr_build_flag.no_ops)) return true;
				
					tk = txr_build_list[|txr_build_pos];
					if (tk[0] != txr_token.sqb_close) return txr_throw_at("Expected a closing []", tk);
					txr_build_pos += 1;
					txr_build_node = [txr_node.array_access, tk[1], node, txr_build_node];
				} else return txr_throw_at("Unexpected `.`", tk);
				break;
			case txr_token.adjfix: // value++?
				if ((flags & txr_build_flag.no_suffix) == 0) {
					txr_build_pos += 1;
					txr_build_node = [txr_node.postfix, tk[1], txr_build_node, tk[2]];
				} else return txr_throw_at("Unexpected postfix", tk);
				break;
			case txr_token.op: // value + ...?
				if ((flags & txr_build_flag.no_ops) == 0) {
					txr_build_pos += 1;
					if (txr_build_ops(tk)) return true;
					flags |= txr_build_flag.no_suffix;
				} else _break = true;
				break;
			default: _break = true;
		}
		if (_break) break;
	}

	return false;
}
