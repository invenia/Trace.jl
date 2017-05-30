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

    function TraceRecord(
        name::AbstractString,
        level::AbstractString,
        levelnum::Int,
        msg::AbstractString,
        metrics::Dict=Dict{Symbol, Real}()
    )
        time = now()
        trace = Attribute(StackTrace, Memento.get_trace)

        new(
            Attribute(DateTime, () -> round(time, Base.Dates.Second)),
            Attribute(level),
            Attribute(levelnum),
            Attribute(AbstractString, Memento.get_msg(msg)),
            Attribute(name),
            Attribute(myid()),
            Attribute(StackFrame, Memento.get_lookup(trace)),
            trace,
            Attribute(get(metrics, :time, "NaN seconds")),
            Attribute(get(metrics, :alloc, "NaN bytes")),
            Attribute(get(metrics, :gctime, "NaN % gc time")),
            Attribute(get(metrics, :nalloc, "NaN")),
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

    args = Dict(
        :time => "$(round(elapsedtime / 1e9, 6)) seconds",
        :alloc => datasize(diff.allocd, style=:bin, format="%.3f"),
        :gctime => "$(round(100 * diff.total_time / elapsedtime, 4)) % gc time",
        :nalloc => _humanize_alloc(Base.gc_alloc_count(diff))
    )

    msg = string(
        "`$(string(f))` <",
        "Time: $(args[:time]) ($(args[:gctime])), ",
        "Allocated: $(args[:alloc]) ($(args[:nalloc]))>"
    )

    rec = TraceRecord(logger.name, "trace", logger.levels["trace"], msg, args)
    @sync log(logger, rec)

    return val
end

trace(logger::Logger, f::Function, args...; kwargs...) = trace(f, logger, args...; kwargs...)

# Simple utility method for humanizing the number of allocations.
function _humanize_alloc(n)
    alloc, ma = Base.prettyprint_getunits(n, length(Base._cnt_units), Int64(1000))
    return "$(alloc)$(Base._cnt_units[ma])"
end
