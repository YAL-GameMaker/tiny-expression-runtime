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
}
enum txr_op {
    mul  = 0x01, // *
    fdiv = 0x02, // /
    fmod = 0x03, // %
    idiv = 0x04, // div
    add  = 0x10, // +
    sub  = 0x11, // -
	maxp = 0x20 // maximum priority
}

// builder:
#macro txr_build_list global.txr_build_list_val
#macro txr_build_node global.txr_build_node_val
#macro txr_build_pos  global.txr_build_pos_val
#macro txr_build_len  global.txr_build_len_val
global.txr_function_map = ds_map_create();
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
}
enum txr_unop {
	negate = 1, // -value
}
enum txr_build_flag {
	no_ops = 1
}

// compiler:
#macro txr_compile_list global.txr_compile_list_val
txr_compile_list = ds_list_create();
enum txr_action {
	number = 1, // (value): push(value)
	ident = 2, // (name): push(self[name])
	unop = 3, // (unop): push(-pop())
	binop = 4, // (op): a = pop(); b = pop(); push(binop(op, a, b))
	call = 5, // (script, argc): 
	ret = 6, // (): return pop()
	discard = 7, // (): pop() - for when we don't care for output
	jump = 8, // (pos): pc = pos
	jump_unless = 9, // (pos): if (!pop()) pc = pos
	_string = 10, // (value:string): push(value)
}
#macro txr_function_error global.txr_function_error_val
txr_function_error = undefined;
global.txr_exec_args = ds_list_create();