open OUnit
open Flock

(* Helper functions *)

(*BISECT-IGNORE-BEGIN*)
let finally f g =
  let res = try f () with e -> g (); raise e in g (); res

let with_open_file path f =
  let fd = Unix.(openfile path [O_CREAT; O_TRUNC; O_RDWR] 0o600) in
  finally (fun () -> f fd) (fun () -> Unix.close fd)

let with_temp_file f =
  let path = Filename.temp_file "test_flock" ".lock" in
  finally (fun () -> with_open_file path (f path)) (fun () -> Unix.unlink path)

let string_of_operation = function
  | LOCK_EX -> "exclusive"
  | LOCK_SH -> "shared"
  | LOCK_UN -> "unlock"

let sleep s = Unix.select [] [] [] s |> ignore
(*BISECT-IGNORE-END*)

(* Test cases *)

let smoke_test =
  "Smoke test that we can call the function at all" >:: fun () ->
  with_temp_file (fun path fd -> flock fd LOCK_EX)

let exclusion_tests =
  let try_lock with_mode try_mode expectation =
    with_temp_file (fun path fd ->
      flock fd with_mode;
      with_open_file path (fun fd' ->
        let lock_f () = flock ~nonblocking:true fd' try_mode in
        if expectation then lock_f ()
        else assert_raises Unix.(Unix_error(EAGAIN, "flock", "")) lock_f
      )
    ) in
  let test_vector = [
    (LOCK_EX, LOCK_EX, false);
    (LOCK_EX, LOCK_SH, false);
    (LOCK_SH, LOCK_EX, false);
    (LOCK_SH, LOCK_SH, true);
  ] in
  List.map (fun (with_mode, try_mode, expectation) ->
    let tc_title =
      Printf.sprintf "Test %s lock can%s be acquired while %s lock held"
        (string_of_operation try_mode)
        (if expectation then "" else "not")
        (string_of_operation with_mode) in
    tc_title >:: fun () -> try_lock with_mode try_mode expectation
  ) test_vector

let test_unlock =
  "Test that unlocking allows re-acquisition of the lock" >:: fun () ->
  with_temp_file (fun path fd ->
    flock fd LOCK_EX;
    with_open_file path (fun fd' ->
      let lock_f () = flock ~nonblocking:true fd' LOCK_EX in
      assert_raises Unix.(Unix_error(EAGAIN, "flock", "")) lock_f;
      flock fd LOCK_UN;
      lock_f ()
    )
  )

let test_unlock_blocking =
  "Test unlocking unblocks a blocked attempt to acquire the lock" >:: fun () ->
  (* Note, we can't do this with threads because of the caml_blocking_section
   * in the bindings and the global interpreter lock *)
  with_temp_file (fun path fd ->
    flock fd LOCK_EX;
    let _ = Unix.open_process ("flock -x " ^ path ^ " -c true") in
    assert_bool "flock(1) did not block waiting for lock"
      Unix.(waitpid [ WNOHANG ] 0 |> fst = 0);
    flock fd LOCK_UN;
    sleep 0.1;
    assert_bool "flock(1) did not unblock when lock released"
      Unix.(waitpid [ WNOHANG ] 0 |> fst <> 0);
  )

let test_operation_idemptotence =
  "Check all operations are idempotent on a given file desciptor" >:: fun () ->
  List.iter (fun op ->
    let f fd = flock ~nonblocking:true fd op in
    with_temp_file (fun _ fd -> f fd; f fd)
  ) [ LOCK_EX; LOCK_SH; LOCK_UN ]

let test_bad_fd =
  "Test expected exception for locking a bad file descriptor" >:: fun () ->
  let closed_fd = with_temp_file (fun _ fd -> fd) in
  assert_raises Unix.(Unix_error(EBADF, "flock", "")) (fun () ->
    flock closed_fd LOCK_EX
  )

let _ =
  let suite = "flock" >::: [
      smoke_test;
      test_unlock;
      test_unlock_blocking;
      test_operation_idemptotence;
      test_bad_fd;
  ] @ exclusion_tests in
  OUnit2.run_test_tt_main @@ ounit2_of_ounit1 suite
