using Trace
using Base.Test
using Memento

# General usage
@trace "My skipped message"
logger = @Trace.config(Trace.DEFAULT_FMT_STRING, IOBuffer())
@trace "My logged message"
log_str = takebuf_string(logger.handlers["default"].io)
@test contains(log_str, "trace")
@test contains(log_str, "My logged message")

# Check that skipping is significantly longer
Memento.reset!()
skip_trace = median(map(1:1000) do i
    tic()
    @trace "My skipped message"
    return toq()
end)

@Trace.config(Trace.DEFAULT_FMT_STRING, IOBuffer())
log_trace = median(map(1:1000) do i
    tic()
    @trace "My logged message"
    return toq()
end)

logger = Logger(
    "Logger.example";
    level="info",
    propagate=false
)

add_handler(
    logger,
    DefaultHandler(
        IOBuffer(), DefaultFormatter(Memento.DEFAULT_FMT_STRING)
    ),
    "Buffer"
)

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
