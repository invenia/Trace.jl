module Trace

using Memento
using Humanize

import Memento: Attribute

global const TRACE_LEVEL = 5
global const LOG_FMT_STRING = "[{level}]: {msg}"
global const TRACE_FMT_STRING = "[{msg}] {time} ({nalloc} allocations: {alloc}, {gctime})"

export @log, @trace

# TODO: fix up configuration of the `@log` vs `@trace` macros

type TraceRecord <: Record
    date::Attribute
    level::Attribute
    levelnum::Attribute
    msg::Attribute
    name::Attribute
    pid::Attribute
    lookup::Attribute
    stacktrace::Attribute
    time::Attribute
    alloc::Attribute
    gctime::Attribute
    nalloc::Attribute

    function TraceRecord(msg::AbstractString, metrics::Dict=Dict{Symbol, Real}())
        time = now()
        trace = Attribute(StackTrace, Memento.get_trace)

        new(
            Attribute(DateTime, () -> round(time, Base.Dates.Second)),
            Attribute("trace"),
            Attribute(-1),
            Attribute(AbstractString, Memento.get_msg(msg)),
            Attribute("Trace"),
            Attribute(myid()),
            Attribute(StackFrame, Memento.get_lookup(trace)),
            trace,
            Attribute(AbstractString, () -> "$(get(metrics, :time, NaN)) seconds"),
            Attribute(AbstractString, () -> datasize(get(metrics, :alloc, NaN), style=:bin, format="%.3f")),
            Attribute(AbstractString, () -> "$(get(metrics, :gctime, NaN)) %"),
            Attribute(AbstractString, () -> _humanize_alloc(get(metrics, :nalloc, NaN))),
        )
    end
end

"""
    @config(logfmt=Trace.LOG_FMT_STRING, tracefmt=Trace.TRACE_FMT_STRING, io=STDOUT)

Sets up a "trace" log level and creates a "Trace" logger which we'll be using for all
`@log` and `@trace` messages.

NOTE: By default 2 handlers will be attached to the "Trace" logger for emitting
`@log` and `@trace` messages to STDOUT with the appropriate formatting.
More handlers can always be added with:

```
add_handler(get_logger("Trace"), syslog_handler, "syslog")
```
"""
macro config(ex...)
    kwargs = try
        map(x -> Pair(x.args...), ex) |> Dict
    catch _
        throw(ArgumentError("Expected keyword arguments, but got $ex"))
    end

    logfmt = get(kwargs, :logfmt, LOG_FMT_STRING)
    tracefmt = get(kwargs, :tracefmt, TRACE_FMT_STRING)
    io = get(kwargs, :io, STDOUT)

    quote
        Memento._log_levels["trace"] = 5
        Memento._loggers["Trace"] = Logger(
            "Trace";
            level="trace",
            propagate=false
        )

        log_handler = DefaultHandler($io, DefaultFormatter($logfmt))
        push!(log_handler.filters, Memento.Filter(r -> !isa(r, TraceRecord)))
        add_handler(Memento._loggers["Trace"], log_handler, "log-stdout")

        trace_handler = DefaultHandler($io, DefaultFormatter($tracefmt))
        push!(trace_handler.filters, Memento.Filter(r -> isa(r, TraceRecord)))
        add_handler(Memento._loggers["Trace"], trace_handler, "trace-stdout")

        Memento._loggers["Trace"]
    end
end

"""
    @log(msg)

Logs the `msg` to the "Trace" logger.
"""
macro log(msg)
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

"""
    @trace(ex)

Monitors execution time and memory allocation for the expression and automatically
logs those metrics to the "Trace" logger.
"""
macro trace(ex)
    if haskey(Memento._loggers, "Trace")
        logger = Memento._loggers["Trace"]
        level = logger.level
        levelnum = logger.levels[level]

        if levelnum <= TRACE_LEVEL
            if ex.head === :call
                return Expr(
                    :call,
                    Trace.trace,
                    esc(ex.args[1]),
                    logger,
                    ex.args[2:end]...
                )
                # return :(trace($(ex.args[1]), $logger, $(ex.args[2:end])...))
            else
                throw(ArgumentError("Expr $ex is not callable"))
            end
        end
    end

    return ex
end

function trace(f::Function, logger::Logger, args...; kwargs...)
    stats = Base.gc_num()
    elapsedtime = Base.time_ns()

    val = f(args...; kwargs...)

    elapsedtime = Base.time_ns() - elapsedtime
    diff = Base.GC_Diff(Base.gc_num(), stats)
    rec = TraceRecord(
        string(f),
        Dict(
            :time => elapsedtime / 1e9,
            :alloc => diff.allocd,
            :gctime => 100 * diff.total_time / elapsedtime,
            :nalloc => Base.gc_alloc_count(diff)
        )
    )
    @sync log(logger, rec)

    return val
end

function _humanize_alloc(n)
    if !isnan(n)
        alloc, ma = Base.prettyprint_getunits(n, length(Base._cnt_units), Int64(1000))
        return "$(alloc)$(Base._cnt_units[ma])"
    else
        return "$n"
    end
end

end  # module
