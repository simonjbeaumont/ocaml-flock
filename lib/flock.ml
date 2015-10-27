open Ctypes

module B = Ffi_bindings.Bindings(Ffi_generated)
module T = Ffi_bindings.Types(Ffi_generated_types)

type lock_operation = LOCK_SH | LOCK_EX | LOCK_UN
let int_of_lock_operation = function
  | LOCK_SH -> T.Lock_operation.lock_shared
  | LOCK_EX -> T.Lock_operation.lock_exclusive
  | LOCK_UN -> T.Lock_operation.lock_unlock

let crush_flags f =
  List.fold_left (fun i o -> i lor (f o)) 0
let id x = x

let flock ?(non_blocking=false) fd operation =
  let flags = [ int_of_lock_operation operation ] in
  B.flock (Obj.magic fd) (crush_flags id flags)
