let () =
	print_endline "#include <sys/file.h>";
  Cstubs.Types.write_c Format.std_formatter (module Ffi_bindings.Types)
