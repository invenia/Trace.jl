const global logfuncs = (
    "log",
    "debug",
    "info",
    "notice",
    "warn",
    "error",
    "critical",
    "alert",
    "emergency",
)

macro_msg(name) = """
    @$name(args...)

Executes $name(args...) only when tracing is enabled (`Trace.enable()`).
"""

for name in logfuncs
    fn = Symbol(name)
    docstring = macro_msg(name)

    @eval begin
        @doc macro_msg($name) macro $fn(args...)
            if ENABLED::Bool
                return Expr(:call, $fn, (esc(a) for a in args)...)
            else
                return esc(:nothing)
            end
        end
    end
end


"""
    @trace(logger, ex)

Monitors execution time and memory allocation for the expression and automatically
logs those metrics to the `logger`.
"""
macro trace(logger, ex)
    ENABLED::Bool || return esc(:nothing)

    if ex.head === :call
        return Expr(:call, Trace.trace, esc(logger), (esc(a) for a in ex.args)...)
    else
        throw(ArgumentError("Expr $ex is not callable"))
    end
end
