function txr_init() {
	//!#import "global"
	
	// configuration:
	#macro txr_value_calls 1
	
	#macro txr_error global.txr_error_val

	// parser:
	#macro txr_parse_tokens global.txr_parse_tokens_val
	txr_parse_tokens = ds_list_create();
	enum txr_token {
		eof = 0, // <end of file>
		op = 1, // + - * / % div
		par_open = 2, // (
		par_close = 3, // )
		number = 4, // 37
		ident = 5, // some
		comma = 6, // ,
		ret = 7, // return
		_if = 8,
		_else = 9,
		_string = 10, // "hi!"
		cub_open = 11, // {
		cub_close = 12, // }
		set = 13, // = += -= etc
		unop = 14, // !
		_while = 15,
		_do = 16,
		_for = 17,
		semico = 18, // ;
		_break = 19,
		_continue = 20,
		_var = 21,
		_argument = 22, // argument#
		_argument_count = 23,
		label = 24,
		jump = 25,
		jump_push = 26,
		jump_pop = 27,
		colon = 28, // :
		_select = 29,
		_option = 30,
		_default = 31,
		adjfix = 32, // (delta) ++/--
		_switch = 33,
		_case = 34,
		period = 35, // .
		sqb_open = 36,
		sqb_close = 37,
	}
	enum txr_op {
		set  =   -1, // =
		mul  = 0x01, // *
		fdiv = 0x02, // /
		fmod = 0x03, // %
		idiv = 0x04, // div
		add  = 0x10, // +
		sub  = 0x11, // -
		shl  = 0x20, // <<
		shr  = 0x21, // >>
		iand = 0x30, // &
		ior  = 0x31, // |
		ixor = 0x32, // ^
		eq   = 0x40, // ==
		ne   = 0x41, // !=
		lt   = 0x42, // <
		le   = 0x43, // <=
		gt   = 0x44, // >
		ge   = 0x45, // >=
		band = 0x50, // &&
		bor  = 0x60, // ||
		maxp = 0x70, // maximum priority
	}
	var ops/*:txr_op*/ = array_create(txr_op.maxp, "an operator");
	ops[@txr_op.mul] = "*";
	ops[@txr_op.fdiv] = "/";
	ops[@txr_op.fmod] = "%";
	ops[@txr_op.idiv] = "div";
	ops[@txr_op.add] = "+";
	ops[@txr_op.sub] = "-";
	ops[@txr_op.shl] = "<<";
	ops[@txr_op.shr] = ">>";
	ops[@txr_op.iand] = "&";
	ops[@txr_op.ior] = "|";
	ops[@txr_op.ixor] = "^";
	ops[@txr_op.eq] = "==";
	ops[@txr_op.ne] = "!=";
	ops[@txr_op.lt] = "<";
	ops[@txr_op.le] = "<=";
	ops[@txr_op.gt] = ">";
	ops[@txr_op.ge] = ">=";
	ops[@txr_op.band] = "&&";
	ops[@txr_op.bor] = "||";
	global.txr_op_names = ops;


	// builder:
	#macro txr_build_list global.txr_build_list_val
	#macro txr_build_node global.txr_build_node_val
	#macro txr_build_pos  global.txr_build_pos_val
	#macro txr_build_len  global.txr_build_len_val
	#macro txr_build_can_break    global.txr_build_can_break_val
	#macro txr_build_can_continue global.txr_build_can_continue_val
	#macro txr_build_locals global.txr_build_locals_val
	txr_build_locals = ds_map_create(); // <varname:string, is_local:bool>
	
	global.txr_function_map = ds_map_create(); // <funcname:string, [script, argcount]>
	global.txr_constant_map = ds_map_create(); // <constname:string, value>
	enum txr_node {
		number = 1, // (val:number)
		ident = 2, // (name:string)
		unop = 3, // (unop, node)
		binop = 4, // (binop, a, b)
		call = 5, // (script, args_array)
		block = 6, // (nodes_array) { ...nodes }
		ret = 7, // (node) return <node>
		discard = 8, // (node) - when we don't care
		if_then = 9, // (cond_node, then_node)
		if_then_else = 10, // (cond_node, then_node, else_node)
		_string = 11, // (val:string)
		set = 12, // (binop, node, value:node)
		_while = 13,
		do_while = 14,
		_for = 15,
		_break = 16,
		_continue = 17,
		_argument = 18, // (index:int)
		_argument_count = 19,
		label = 20, // (name:string)
		jump = 21, // (name:string)
		jump_push = 22, // (name:string)
		jump_pop = 23, // ()
		_select = 24, // (call_node, nodes, ?default_node)
		prefix = 25, // (node, delta) ++x/--x
		postfix = 26, // (node, delta) x++/x--
		adjfix = 27, // (node, delta) x+=1/x-=1 (statement)
		_switch = 28, // (expr, case_values, case_exprs, ?default_node)
		field = 29, // (node, field:string)
		array_access = 30, // (node, index)
		array_literal = 31, // (nodes)
		value_call = 32, // (node, args_array)
		object_literal = 33, // (key_strings, value_nodes)
	}
	enum txr_unop {
		negate = 1, // -value
		invert = 2, // !value
	}
	enum txr_build_flag {
		no_ops = 1, // no <expr> + ...
		no_suffix = 2, // no <expr>.field, <expr>[index], etc.
	}

	// compiler:
	#macro txr_compile_list global.txr_compile_list_val
	txr_compile_list = ds_list_create();
	
	#macro txr_compile_labels global.txr_compile_labels_val
	txr_compile_labels = ds_map_create();
	
	enum txr_action {
		number = 1, // (value:number): push(value)
		ident = 2, // (name): push(self[name])
		unop = 3, // (unop): push(-pop())
		binop = 4, // (op): a = pop(); b = pop(); push(binop(op, a, b))
		call = 5, // (script, argc): 
		ret = 6, // (): return pop()
		discard = 7, // (): pop() - for when we don't care for output
		jump = 8, // (pos): pc = pos
		jump_unless = 9, // (pos): if (!pop()) pc = pos
		_string = 10, // (value:string): push(value)
		set_ident = 11, // (name:string): self[name] = pop()
		band = 12, // (pos): if (peek()) pop(); else pc = pos
		bor = 13, // (pos): if (peek()) pc = pos; else pop()
		jump_if = 14, // (pos): if (pop()) pc = pos
		get_local = 15, // (name): push(locals[name])
		set_local = 16, // (name): locals[name] = pop()
		jump_push = 17, // (pos): js.push(pc); pc = pos
		jump_pop = 18, // (): pc = js.pop()
		_select = 19, // (pos_array, def_pos): the simplest jumptable
		dup = 20, // push(top())
		_switch = 21, // (pos): if (pop() == peek()) { pop(); pc = pos; }
		label = 22, // (name:string) [does nothing]
		get_field = 23, // (name:string): push(pop().name)
		set_field = 24, // (name:string): { v = pop(); pop().name = v; }
		get_array = 25, // (): i = pop(); push(pop()[i])
		set_array = 26, // (): v = pop(); i = pop(); pop()[i] = v;
		array_literal = 27, // (n): 
		value_call = 28, // (argc): args = pop#argc(); fn = pop(); push(fn(...args))
		object_literal = 29, // (field_names): 
		sizeof,
	}
	
	/// If assigned, any calls to unknown functions will instead call this with
	/// function name as the first argument
	#macro txr_function_default global.txr_function_default_val
	txr_function_default = -1;
	/// Can be assigned to by your functions to throw an error
	#macro txr_function_error global.txr_function_error_val
	txr_function_error = undefined;
	/// Currently executing TXR "thread". Modified by txr_thread_resume
	#macro txr_thread_current global.txr_thread_current_val
	txr_thread_current = undefined;
	// Reused
	global.txr_exec_args = ds_list_create();
}
// GMEdit hints:
/// @typedef {buffer} Buffer
