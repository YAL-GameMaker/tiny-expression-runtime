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
    set = 13, // =
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
}
enum txr_op {
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
    set = 12, // (node, value:node)
    _while = 13,
    do_while = 14,
    _for = 15,
    _break = 16,
    _continue = 17,
    _argument = 18, // (index:int)
    _argument_count = 19,
}
enum txr_unop {
    negate = 1, // -value
    invert = 2, // !value
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
    set_ident = 11, // (name:string): self[name] = pop()
    band = 12, // (pos): if (peek()) pop(); else pc = pos
    bor = 13, // (pos): if (peek()) pc = pos(); else pop()
    jump_if = 14, // (pos): if (pop()) pc = pos
    get_local = 15, // (name): push(locals[name])
    set_local = 16, // (name): locals[name] = pop()
}
#macro txr_function_default global.txr_function_default_val
txr_function_default = -1;
#macro txr_function_error global.txr_function_error_val
txr_function_error = undefined;
global.txr_exec_args = ds_list_create();