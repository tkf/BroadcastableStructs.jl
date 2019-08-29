using Documenter, BroadcastableStructs

makedocs(;
    modules=[BroadcastableStructs],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/BroadcastableStructs.jl/blob/{commit}{path}#L{line}",
    sitename="BroadcastableStructs.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/tkf/BroadcastableStructs.jl",
)
