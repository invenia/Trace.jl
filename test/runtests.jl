using Trace
using Base.Test
using Memento

@testset "Basic Usage" begin
    @trace "My skipped message"
    @Trace.config(Trace.DEFAULT_FMT_STRING, IOBuffer())
    @trace "My logged message"
    # io = get_handlers(get_logger("Trace"))["base"].io
    # log_str = takebuf_string(io)
    # println(log_str)
    # @test contains(log_str, "trace")
    # @test contains(log_str, "My logged message")
end
