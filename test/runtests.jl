using StaticArraysCore, Test

@testset "types" begin
    @test StaticArraysCore.SArray{Tuple{2},Int,1}((1, 2)) isa StaticArraysCore.SArray
end

