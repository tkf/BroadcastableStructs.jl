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
    strict=v"1.2" <= VERSION < v"1.3",
)

deploydocs(;
    repo="github.com/tkf/BroadcastableStructs.jl",
)
