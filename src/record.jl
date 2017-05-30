"""
    TraceRecord <: Record

Stores extra metrics (e.g., execution time, memory allocated) about a function
call for trace records.
"""
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
            Attribute(AbstractString, () -> "$(get(metrics, :gctime, NaN)) % gc time"),
            Attribute(AbstractString, () -> _humanize_alloc(get(metrics, :nalloc, NaN))),
        )
    end
end

"""
    trace(f, logger, args...; kwargs...)

Wrapper function which measures the executions time and memory allocation
of function `f(args...; kwargs...)` and logs the resulting `TraceRecord`.
"""
function trace(f::Function, logger::Logger, args...; kwargs...)
    stats = Base.gc_num()
    elapsedtime = Base.time_ns()

    val = f(args...; kwargs...)

    elapsedtime = Base.time_ns() - elapsedtime
    diff = Base.GC_Diff(Base.gc_num(), stats)
    msg = "Function: $(string(f)) Time: {time} ({gctime}), Allocated: {alloc} ({nalloc})"
    rec = TraceRecord(
        string(f),
        "trace",
        logger.levels["trace"],
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

trace(logger::Logger, f::Function, args...; kwargs...) = trace(f, logger, args...; kwargs...)

# Simple utility method for humanizing the number of allocations.
function _humanize_alloc(n)
    if !isnan(n)
        alloc, ma = Base.prettyprint_getunits(n, length(Base._cnt_units), Int64(1000))
        return "$(alloc)$(Base._cnt_units[ma])"
    else
        return "$n"
    end
end
