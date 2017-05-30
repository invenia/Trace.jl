using Trace
using Base.Test
using Memento

const FMT_STR = "[{level}]:{name} - {msg}"
const LEVELS = Dict(
    "not_set" => 0,
    "trace" => 5,
    "debug" => 10,
    "info" => 20,
    "warn" => 30,
    "error" => 40,
)

io = IOBuffer()

handler = DefaultHandler(
    io, DefaultFormatter(FMT_STR)
)

logger = Logger(
    "Logger.example",
    Dict("Buffer" => handler),
    "info",
    LEVELS,
    DefaultRecord,
    true
)

skip_trace = median(map(1:1000) do i
    tic()
    @info(logger, "My skipped message")
    res = toq()
    @test isempty(takebuf_string(io))
    return res
end)

# enable tracing
Trace.enable()

log_trace = median(map(1:1000) do i
    tic()
    @info(logger, "My logged message")
    res = toq()
    @test contains(takebuf_string(io), "My logged message")
    return res
end)

# Compare against logging alone
skip_log = median(map(1:1000) do i
    tic()
    debug(logger, "My skipped message")
    return toq()
end)

log_log = median(map(1:1000) do i
    tic()
    info(logger, "My skipped message")
    return toq()
end)

println("Skipped trace time: $skip_trace")
println("Skipped log time: $skip_log")
println("Logged trace time: $log_trace")
println("Logged log time: $log_log")

@test skip_trace < skip_log
@test skip_trace < log_trace

set_level(logger, "trace")
@trace(logger, median(rand(1000)))
