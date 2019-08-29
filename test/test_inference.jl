module TestInference

include("preamble.jl")

madd = ManyAdd()

@test_broken_inferred bcapp(madd, 1:5...)

end  # module
