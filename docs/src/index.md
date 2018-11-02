# Trace
[![stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Trace.jl/stable)
[![latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/Trace.jl/latest)
[![Build Status](https://travis-ci.org/invenia/Trace.jl.svg?branch=master)](https://travis-ci.org/invenia/Trace.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/invenia/Trace.jl?svg=true)](https://ci.appveyor.com/project/invenia/Trace-jl)
[![codecov](https://codecov.io/gh/invenia/Trace.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Trace.jl)

Trace provides a minimal interface for zero overhead program tracing in julia.

## Macros

[Macro](https://docs.julialang.org/en/release-0.5/manual/metaprogramming/#macros) versions of the logging methods (e.g., `log`, `debug`, `info`) provided in [Memento](https://github.com/invenia/Memento.jl) are used to only include logging expressions in the compiled source when tracing has been enabled (`Trace.enable()`).

Example)
```julia
using Memento
using Trace

# Configure Memento logging as usual.
logger = Memento.config!("debug"; fmt="[{level} | {name}]: {msg}")

# NOTE: We're enabling tracing prior to loading any of the macro
# expressions that depend on it.
Trace.enable()  # Sets `Trace.ENABLED` and adds a "trace" logging level.

# Might want to include another package that includes tracing expressions.
# using MyTracedPkg

# Log a debug message when tracing is enabled.
@debug(logger, "Something to help you track down a bug.")
```

**NOTE**: The `@debug` expression would be excluded at runtime if `Trace.enable()` was commented out.

## Tracing functions

As program tracing lies somewhere between logging and profiling it is not uncommon to want to automatically log execution time and memory allocation of a function.
Trace provides an `@trace(logger, ex)` macro for doing exactly this.

Example)
```julia
# Assuming similar code to above
...

# Set the logging level to "trace" (5) which defaults to having a
# lower priority logging than "debug" (10).
setlevel!(logger, "trace")


# Same behaviour as `@debug` with regard to `Trace.enable()`.
@trace(logger, rand(1000, 1000))
```
