Name
====

luajit2-test-suite - OpenResty's branch of Mike Pall's LuaJIT 2 test suite.

Table of Contents
=================

* [Name](#name)
* [Synopsis](#synopsis)
* [Prerequisites](#prerequisites)
* [Original Notes](#original-notes)

Synopsis
=========

```bash
# run the test suite in normal test mode with the luajit installed under /opt/luajit21/
./run-tests.pl /opt/luajit21

# run the test suite in valgrind test mode with luajit installed under /opt/luajit21sysm/
./run-tests.pl /opt/luajit21sysm 1
```

When all the tests are passing, the output should look like this:

```
```

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

Original Notes
==============

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

