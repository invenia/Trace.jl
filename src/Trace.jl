module Trace

using Base: StackTrace
using Compat.Dates
using Compat.Distributed
using Memento
using Humanize

using Compat: round
using Humanize: datasize

import Memento: Attribute

global ENABLED = false

if isdefined(Base, Symbol("@info")) # Turned into macros in 0.7
    import Base: @info, @warn
else
    export
        @info,
        @warn
end

export
    @log,
    @trace,
    @debug,
    @notice,
    @error,
    @critical,
    @alert,
    @emergency

"""
    Trace.enable()

Enables logging for all subsequent tracing macros and adds a "trace" (5) logging level.
"""
function enable()
    ENABLED::Bool &&  return  # exit early if enabled has already been set
    global ENABLED = true
    addlevel!(getlogger(), "trace", 5)
end

include("record.jl")
include("macros.jl")

end  # module
