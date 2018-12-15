/// Causes the currently executing thread to yield,
/// suspending it's execution. The thread can later
/// be resumed by calling txr_thread_resume(th, result)
/// and `result` will be returned to the resuming code.
/// See https://en.wikipedia.org/wiki/Coroutine
var th/*:txr_thread*/ = txr_thread_current;
if (th != undefined) {
    th[@txr_thread.status] = txr_thread_status.yield;
    return th;
} else return undefined;