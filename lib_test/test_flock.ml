open OUnit
open Flock

let finally f g =
  let res = try f () with e -> g (); raise e in g (); res

let with_open_file path f =
  let fd = Unix.(openfile path [O_CREAT; O_TRUNC; O_RDWR] 0o600) in
  finally (fun () -> f fd) (fun () -> Unix.close fd)

let with_temp_file f =
  let path = Filename.temp_file "test_flock" ".lock" in
  finally (fun () -> with_open_file path f) (fun () -> Unix.unlink path)

let smoke_test =
  "Smoke test that we can call the function at all" >:: fun () ->
  with_temp_file (fun fd -> flock fd LOCK_EX |> ignore)

let _ =
  let suite = "flock" >::: [
      smoke_test;
  ] in
  OUnit2.run_test_tt_main @@ ounit2_of_ounit1 suite
