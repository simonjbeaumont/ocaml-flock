module B = Ffi_bindings.Foreign_bindings
module S = Ffi_bindings.Bindings(Ffi_generated)
module T = Ffi_bindings.Types(Ffi_generated_types)

type lock_operation = LOCK_SH | LOCK_EX | LOCK_UN

let flag_of_lock_operation = function
  | LOCK_SH -> T.Lock_operation.lock_shared
  | LOCK_EX -> T.Lock_operation.lock_exclusive
  | LOCK_UN -> T.Lock_operation.lock_unlock

let nonblocking_flag = T.Lock_operation.lock_nonblocking

let crush_flags =
  List.fold_left (fun acc flag -> acc lor flag) 0

let flock ?(nonblocking=false) fd operation =
  let op_flag = flag_of_lock_operation operation in
  let flags = op_flag :: if nonblocking then [ nonblocking_flag ] else [] in
  B.flock (Obj.magic fd) (crush_flags flags) |> ignore
