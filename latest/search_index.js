var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Trace-1",
    "page": "Home",
    "title": "Trace",
    "category": "section",
    "text": "(Image: stable) (Image: latest) (Image: Build Status) (Image: Build status) (Image: codecov)Trace provides a minimal interface for zero overhead program tracing in julia."
},

{
    "location": "index.html#Macros-1",
    "page": "Home",
    "title": "Macros",
    "category": "section",
    "text": "Macro versions of the logging methods (e.g., log, debug, info) provided in Memento are used to only include logging expressions in the compiled source when tracing has been enabled (Trace.enable()).Example)using Memento\nusing Trace\n\n# Configure Memento logging as usual.\nlogger = Memento.config(\"debug\"; fmt=\"[{level} | {name}]: {msg}\")\n\n# NOTE: We're enabling tracing prior to loading any of the macro\n# expressions that depend on it.\nTrace.enable()  # Sets `Trace.ENABLED` and adds a \"trace\" logging level.\n\n# Might want to include another package that includes tracing expressions.\n# using MyTracedPkg\n\n# Log a debug message when tracing is enabled.\n@debug(logger, \"Something to help you track down a bug.\")NOTE: The @debug expression would be excluded at runtime if Trace.enable() was commented out."
},

{
    "location": "index.html#Tracing-functions-1",
    "page": "Home",
    "title": "Tracing functions",
    "category": "section",
    "text": "As program tracing lies somewhere between logging and profiling it is not uncommon to want to automatically log execution time and memory allocation of a function. Trace provides an @trace(logger, ex) macro for doing exactly this.Example)# Assuming similar code to above\n...\n\n# Set the logging level to \"trace\" (5) which defaults to having a\n# lower priority logging than \"debug\" (10).\nset_level(logger, \"trace\")\n\n\n# Same behaviour as `@debug` with regard to `Trace.enable()`.\n@trace(logger, rand(1000, 1000))"
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#Trace.enable",
    "page": "API",
    "title": "Trace.enable",
    "category": "Function",
    "text": "Trace.enable()\n\nEnables logging for all subsequent tracing macros and adds a \"trace\" (5) logging level.\n\n\n\n"
},

{
    "location": "api.html#Trace.@alert-Tuple",
    "page": "API",
    "title": "Trace.@alert",
    "category": "Macro",
    "text": "@alert(args...)\n\nExecutes alert(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@critical-Tuple",
    "page": "API",
    "title": "Trace.@critical",
    "category": "Macro",
    "text": "@critical(args...)\n\nExecutes critical(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@debug-Tuple",
    "page": "API",
    "title": "Trace.@debug",
    "category": "Macro",
    "text": "@debug(args...)\n\nExecutes debug(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@emergency-Tuple",
    "page": "API",
    "title": "Trace.@emergency",
    "category": "Macro",
    "text": "@emergency(args...)\n\nExecutes emergency(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@error-Tuple",
    "page": "API",
    "title": "Trace.@error",
    "category": "Macro",
    "text": "@error(args...)\n\nExecutes error(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@info-Tuple",
    "page": "API",
    "title": "Trace.@info",
    "category": "Macro",
    "text": "@info(args...)\n\nExecutes info(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@log-Tuple",
    "page": "API",
    "title": "Trace.@log",
    "category": "Macro",
    "text": "@log(args...)\n\nExecutes log(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@notice-Tuple",
    "page": "API",
    "title": "Trace.@notice",
    "category": "Macro",
    "text": "@notice(args...)\n\nExecutes notice(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.@trace-Tuple{Any,Any}",
    "page": "API",
    "title": "Trace.@trace",
    "category": "Macro",
    "text": "@trace(logger, ex)\n\nMonitors execution time and memory allocation for the expression and automatically logs those metrics to the logger.\n\n\n\n"
},

{
    "location": "api.html#Trace.@warn-Tuple",
    "page": "API",
    "title": "Trace.@warn",
    "category": "Macro",
    "text": "@warn(args...)\n\nExecutes warn(args...) only when tracing is enabled (Trace.enable()).\n\n\n\n"
},

{
    "location": "api.html#Trace.TraceRecord",
    "page": "API",
    "title": "Trace.TraceRecord",
    "category": "Type",
    "text": "TraceRecord <: Record\n\nStores extra metrics (e.g., execution time, memory allocated) about a function call for trace records.\n\n\n\n"
},

{
    "location": "api.html#Trace.trace",
    "page": "API",
    "title": "Trace.trace",
    "category": "Function",
    "text": "trace(f, logger, args...; kwargs...)\n\nWrapper function which measures the executions time and memory allocation of function f(args...; kwargs...) and logs the resulting TraceRecord.\n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "Trace.enableModules = [Trace]\nPrivate = false\nPages = [\"macros.jl\"]Trace.TraceRecord\nTrace.trace"
},

]}
