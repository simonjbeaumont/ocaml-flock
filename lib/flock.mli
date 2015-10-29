(** A wrapper library around type-safe Ctypes bindings to [flock(2)].

    See the man page for {{:http://linux.die.net/man/2/flock}flock(2)}. *)

(**  {1 Basic types and values} *)

type lock_operation = LOCK_SH | LOCK_EX | LOCK_UN

val flock : ?nonblocking:bool -> Unix.file_descr -> lock_operation -> unit
(** [flock ~nonblocking fd operation] applies or removes an advisory lock on
    the open file specified by [fd]. The argument [operation] is one of the
    following:
    - [LOCK_SH]: Place a shared lock. More than one process may hold a shared
                  lock for a given file at a given time.

    - [LOCK_EX]: Place an exclusive lock. Only one process may hold an
                 exclusive lock for a given file at a given time.

    - [LOCK_UN]: Remove an existing lock held by this process.

    If [nonblocking] is [false] (default), a call to [flock] may block if an
    incompatible lock is held by another process. Otherwise, if [nonblocking]
    is [true] then attempting to acquire a lock that is already held will
    raises [(Unix_error(EAGAIN,_,_)] or [Unix_error(EWOULDBLOCK,_,_)].

    A single file may not simultaneously have both shared and exclusive locks.

    Locks created by [flock] are associated with an open file table entry. This
    means that duplicate file descriptors (created by, for example, [fork(2)]
    or [dup(2)]) refer to the same lock, and this lock may be modified or
    released using any of these descriptors. Furthermore, the lock is released
    either by an explicit [LOCK_UN] operation on any of these duplicate
    descriptors, or when all such descriptors have been closed.

    If a process uses [open(2)] (or similar) to obtain more than one descriptor
    for the same file, these descriptors are treated independently by [flock].
    An attempt to lock the file using one of these file descriptors may be
    denied by a lock that the calling process has already placed via another
    descriptor.

    A process may hold only one type of lock (shared or exclusive) on a file.
    Subsequent [flock] calls on an already locked file will convert an existing
    lock to the new lock mode.

    Locks created by [flock] are preserved across an [execve(2)].

    A shared or exclusive lock can be placed on a file regardless of the mode
    in which the file was opened. *)

(** {1 Errors}

    A call to [flock] could raise one of the following Unix.Unix_errors:
    - [EBADF]: fd is not an open file descriptor.
    - [EINTR]: While waiting to acquire a lock, the call was interrupted by
                delivery of a signal caught by a handler; see signal(7).
    - [ENOLCK]:The kernel ran out of memory for allocating lock records.
    - [EWOULDBLOCK] or [EAGAIN]:
                The file is locked and the [nonblocking] was [true]. *)
