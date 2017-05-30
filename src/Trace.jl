module Trace

using Memento
using Humanize

import Memento: Attribute

global ENABLED = false

export
    @log,
    @trace,
    @debug,
    @info,
    @notice,
    @warn,
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
    add_level(get_logger(), "trace", 5)
end

include(joinpath(Pkg.dir("Trace"), "src", "record.jl"))
include(joinpath(Pkg.dir("Trace"), "src", "macros.jl"))

end  # module
