// This is used to resolve unknown functions
var pg = global.extra_functions[?argument0];
if (pg == undefined) {
    txr_function_error = string(argument0) + " is not a known function or script.";
    exit;
}
return txr_exec(pg);