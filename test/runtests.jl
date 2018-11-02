using Compat.Test
using Trace
using Memento

using Compat: occursin
using Compat.Statistics: median

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
    res = @elapsed begin
        @info(logger, "My skipped message")
    end
    @test isempty(read(io, String))
    return res
end)

# enable tracing
Trace.enable()

log_trace = median(map(1:1000) do i
    res = @elapsed begin
        @info(logger, "My logged message")
    end
    @test occursin(read(io, String), "My logged message")
    return res
end)

# Compare against logging alone
skip_log = median(map(1:1000) do i
    res = @elapsed begin
        debug(logger, "My skipped message")
    end
    return res
end)

log_log = median(map(1:1000) do i
    res = @elapsed begin
        info(logger, "My skipped message")
    end
    return res
end)

println("Skipped trace time: $skip_trace")
println("Skipped log time: $skip_log")
println("Logged trace time: $log_trace")
println("Logged log time: $log_log")

@test skip_trace < skip_log
@test skip_trace < log_trace

setlevel!(logger, "trace")
@trace(logger, median(rand(1000)))
