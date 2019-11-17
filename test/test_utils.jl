module TestUtils

using BroadcastableStructs: foldlargs
using Test

@testset "foldlargs" begin
    @testset for n in 1:20
        @test foldl(string, 1:n, init = 0) == foldlargs(string, 0, 1:n...)
    end
end

end  # module
