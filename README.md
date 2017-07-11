Name
====

luajit2-test-suite - OpenResty's branch of Mike Pall's LuaJIT 2 test suite.

Table of Contents
=================

* [Name](#name)
* [Synopsis](#synopsis)
* [Description](#description)
* [Prerequisites](#prerequisites)
* [TODO](#todo)
* [Original Notes from Mike Pall](#original-notes-from-mike-pall)

Synopsis
=========

```bash
# run the test suite in normal test mode with the luajit installed under /opt/luajit21/
./run-tests /opt/luajit21

# run the test suite in valgrind test mode with luajit installed under /opt/luajit21sysm/
./run-tests /opt/luajit21sysm 1
```

When all the tests are passing, the output should look like this:

```
=== test/unportable/math_special.lua
=== test/misc/hook_norecord.lua
=== test/misc/hook_record.lua
=== test/misc/snap_top2.lua
=== test/misc/strcmp.lua
=== test/misc/string_dump.lua
=== test/misc/tonumber_scan.lua
=== test/misc/api_call.lua
=== test/misc/stackovc.lua
=== test/misc/debug_gc.lua
=== test/misc/stackov.lua
=== test/misc/table_insert.lua
=== test/misc/uclo.lua
=== test/misc/meta_cat.lua
...
=== test/ffi/ffi_jit_misc.lua
=== test/ffi/ffi_call.lua
=== test/ffi/ffi_jit_struct.lua
=== test/ffi/ffi_arith_ptr.lua
=== test/ffi/ffi_callback.lua
=== test/ffi/ffi_metatype.lua
=== test/ffi/ffi_jit_conv.lua
=== test/ffi/ffi_jit_complex.lua
=== test/ffi/ffi_jit_arith.lua
=== test/ffi/ffi_copy_fill.lua
=== test/ffi/ffi_jit_call.lua
=== test/ffi/ffi_tabov.lua
All tests successful.
```

And the whole command will also return the exit code 0 to indicate success.

Failed tests can lead to output like below:

```
=== test/ffi/ffi_type_punning.lua
/opt/luajit21/bin/luajit: ffi_type_punning.lua:57: assertion failed!
stack traceback:
	[C]: in function 'assert'
	ffi_type_punning.lua:57: in main chunk
	[C]: at 0x00404b50
Failed test when running /opt/luajit21/bin/luajit ffi_type_punning.lua 1: 256
=== test/ffi/ffi_err.lua
=== test/ffi/ffi_parse_array.lua
/opt/luajit21/bin/luajit: ../common/ffi_util.inc:22: int __attribute__((aligned(8))) [10]
stack traceback:
	[C]: in function 'assert'
	../common/ffi_util.inc:22: in function 'checktypes'
	ffi_parse_array.lua:32: in main chunk
	[C]: at 0x00404b50
Failed test when running /opt/luajit21/bin/luajit ffi_parse_array.lua 1: 256
=== test/ffi/ffi_const.lua
=== test/ffi/ffi_meta_tostring.lua
=== test/ffi/ffi_convert.lua
/opt/luajit21/bin/luajit: ffi_convert.lua:142: failure expected
stack traceback:
	[C]: in function 'error'
	../common/ffi_util.inc:27: in function 'fails'
	ffi_convert.lua:142: in main chunk
	[C]: at 0x00404b50
Failed test when running /opt/luajit21/bin/luajit ffi_convert.lua 1: 256
=== test/ffi/ffi_parse_cdef.lua
=== test/ffi/ffi_jit_misc.lua
=== test/ffi/ffi_call.lua
=== test/ffi/ffi_jit_struct.lua
=== test/ffi/ffi_arith_ptr.lua
=== test/ffi/ffi_callback.lua
=== test/ffi/ffi_metatype.lua
=== test/ffi/ffi_jit_conv.lua
=== test/ffi/ffi_jit_complex.lua
=== test/ffi/ffi_jit_arith.lua
=== test/ffi/ffi_copy_fill.lua
=== test/ffi/ffi_jit_call.lua
=== test/ffi/ffi_tabov.lua
8 tests failed.
```

In case of test failures, the command will exit with a nonzero status code.

To run tests in multiple parallel jobs so as to utilize more than one CPU cores in your system, you can
specify the `-j N` option where `N` is the number of jobs to run. For example, if you have 8 spare CPU
logical cores in your system, you can run 8 parallel jobs like this:

```
./run-tests -j 8 /opt/luajit21sysm 1
```

The parallel jobs feature is very useful for the valgrind test mode. For example, on my Macbook Pro,
`-j 8` makes the valgrind test mode more than 3x faster than `-j 1` (which is the default).
On the other hand, for the normal mode, running the tests
in multiple jobs actually would make the total running time longer.

Description
===========

This is a test suite for LuaJIT 2.1 based on Mike Pall's personal LuaJIT test suite first published here:

https://github.com/LuaJIT/LuaJIT-test-cleanup

We did not touch Mike's existing test files at all to make sure all the tests still test what they were
originally supposed to test. There is always a big risk in editing Mike's tests since we cannot
easily test those tests with a buggy LuaJIT version.

This test suite is aimed for testing OpenResty's own branch of LuaJIT here:

https://github.com/openresty/luajit2

Prerequisites
=============

This LuaJIT test suite requires some 3rd-party libraries like GTK 2.0, libmpc, mpfr, and C/C++ compilers.

On Fedora, for example, it is sufficient to install the dependencies using a single command:

```bash
sudo dnf install libmpc-devel gtk2-devel mpfr-devel gcc gcc-c++
```

Additionally, the valgrind test mode requires `valgrind`. On Fedora, we can install it via

```bash
sudo dnf install valgrind
```

Currently the `run-tests` script is written in Perl 5. So you may also need to install `perl` if your
system does not have it already. For example, on Fedora, we can do

```bash
sudo dnf install perl
```

If you want to run the tests in multiple parallel jobs, then you should also install the perl CPAN module
`Parallel::ForkManager`. For example, on Fedora, we can install this module like this:

```bash
sudo dnf install perl-Parallel-ForkManager
```

If your operating system does not provide prebuilt package for this perl CPAN module, then you can install
it via the `cpan` command-line utility like this:

```bash
sudo cpan Parallel::ForkManager
```

[Back to TOC](#table-of-contents)

TODO
====

* Run the benchmark scripts as well.
* Integrate as many tests as possible from ROC-Lua 5.1, 5.2, and 5.3.

[Back to TOC](#table-of-contents)

Original Notes from Mike Pall
=============================

In fact it doesn't even have the steps to build it or run it,
so please don't complain.

This repo is a place to collect and cleanup tests for LuaJIT.
They should eventually be merged into the main LuaJIT repo.

It's definitely not in the best state and needs a serious
cleanup effort. Sorry.


Many issues need to be resolved before the merge can be performed:

- Choose a portable test runner
  Requirement: very few dependencies, possibly Lua/Shell only

- Minimal test runner library, wherever assert() is not enough

- Debugging test failures is a lot simpler, when individual tests can still
  be run from the LuaJIT command line without any big dependencies

- Define consistent grouping of all tests

- Define consistent naming of all tests

- Split everything into a lot of tiny tests

- Reduce time taken to run the test suite
  Separate tiers, parallelized testing

- Some tests can only run under certain configurations (e.g. FFI)

- Some tests need a clean slate to give reproducible results
  Most others should be run from the same state for performance resons

- Hard to check that the JIT compiler actually generates the intended code
  Maybe use a test matching variant of the jit.dump module

- Portability concerns

- Avoiding undefined behavior in tests or ignoring it

- Matrix of architectures + configuration options that need testing

- Merge tests from other sources, e.g. the various Lua test suites.

- Tests should go into the LuaJIT git repo, but in separate tarballs
  for the releases


There are some benchmarks, too:

- Some of the benchmarks can be used as tests (with low scaling)
  by checksumming their output and comparing against known good results

- Most benchmarks need different scalings to be useful for comparison
  on all architectures


Note from Mike Pall:

I've removed all tests of undeterminable origin or that weren't explicitly
contributed with the intention of being part of a public test suite.

I hereby put all Lua/LuaJIT tests and benchmarks that I wrote under the
public domain. I've removed any copyright headers.

If I've forgotten an attribution or you want your contributed test to be
removed, please open an issue.

There are some benchmarks that bear other copyrights, probably public
domain, BSD or MIT licensed. If the status cannot be determined, they
need to be replaced or removed before merging with the LuaJIT repo.

[Back to TOC](#table-of-contents)

