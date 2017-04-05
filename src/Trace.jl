module Trace

using Memento

global const TRACE_LEVEL = 5
global const DEFAULT_FMT_STRING = "[{level}]: {msg}"

export @trace

"""
    @config(args...)

Sets up a "trace" log level and creates a "Trace" logger
which we'll be using for all `@trace` messages.

# Arguments (order matters)
* `fmt::AbstractString`: a format string to use (Default=Trace.DEFAULT_FMT_STRING).
* `io::IO`: an IO type to print to (Default=STDOUT).
"""
macro config(args...)
    fmt = length(args) > 0 ? args[1] : DEFAULT_FMT_STRING
    io = length(args) > 1 ? args[2] : STDOUT

    quote
        Memento._log_levels["trace"] = 5
        Memento._loggers["Trace"] = Logger(
            "Trace";
            level="trace",
            propagate=false
        )
        add_handler(
            Memento._loggers["Trace"],
            DefaultHandler(
                $io,
                DefaultFormatter($fmt),
            ),
            "default"
        )

        Memento._loggers["Trace"]
    end
end

"""
    @trace(msg)

Logs the `msg` to the "Trace" logger.
"""
macro trace(msg)
    if haskey(Memento._loggers, "Trace")
        logger = Memento._loggers["Trace"]
        level = logger.level
        levelnum = logger.levels[level]

        if levelnum <= TRACE_LEVEL
            return quote
                rec = Memento._loggers["Trace"].record(
                    "Trace", "trace", TRACE_LEVEL, $msg
                )
                @sync log($logger, rec)
            end
        end
    end

    return :nothing
end

end  # module
