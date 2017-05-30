using Documenter, Trace

makedocs(
    modules=[Trace],
    format=:html,
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
    repo="https://github.com/invenia/Trace.jl/blob/{commit}{path}#L{line}",
    sitename="Trace.jl",
    authors="Invenia Technical Computing Corporation",
    assets=["assets/invenia.css"],
)

deploydocs(
    repo = "github.com/invenia/Trace.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
