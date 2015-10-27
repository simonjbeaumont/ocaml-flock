open Ctypes

module Types (F: Cstubs.Types.TYPE) = struct
  open F
  module Lock_operation = struct
    let lock_shared = constant "LOCK_SH" int
    let lock_exclusive = constant "LOCK_EX" int
    let lock_unlock = constant "LOCK_UN" int
    let lock_nb = constant "LOCK_NB" int
  end
end

module Bindings (F : Cstubs.FOREIGN) = struct
  open F
  let flock = foreign "flock" (int @-> int @-> returning int)
end
