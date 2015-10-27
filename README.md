ocaml-pci
=========

[![Build Status](https://travis-ci.org/simonjbeaumont/ocaml-flock.svg?branch=master)](https://travis-ci.org/simonjbeaumont/ocaml-flock)
[![Coverage Status](https://coveralls.io/repos/simonjbeaumont/ocaml-flock/badge.svg?branch=master)](https://coveralls.io/r/simonjbeaumont/ocaml-flock?branch=master)

Some type-safe C bindings to `flock(2)` and a simple OCaml wrapper function.

If you want to use `flock` and get on with your life then this is for you. Sure
you can get this in Core, but if you only need flock then that's 10 more
minutes building your package and 10 more MB to link it in that you can do
without, right?

## Installation

    ./configure [--enable-tests]
    make
    make install
