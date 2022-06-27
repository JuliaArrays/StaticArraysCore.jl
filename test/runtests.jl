using StaticArraysCore, Test

@testset "types" begin
    @test SArray{Tuple{2},Int,1}((1, 2)) isa SArray
    @test_throws ArgumentError SArray{Tuple{2},Int,2}((1, 2))
    @test SArray{Tuple{2},Float64,1}((1, 2)) isa SVector{2,Float64}
    @test SVector{2,Int}((1, 2)) isa SVector
    @test SMatrix{1,2,Int}((1, 2)) isa SMatrix

    @test MArray{Tuple{2},Int,1}((1, 2)) isa MArray
    @test MArray{Tuple{2},Int,1,2}(undef) isa MArray
    @test MArray{Tuple{2},Float64,1}((1, 2)) isa MVector{2,Float64}
    @test MVector{2,Int}((1, 2)) isa MVector
    @test MMatrix{1,2,Int}((1, 2)) isa MMatrix

    @test SizedArray{Tuple{2},Int,2,1,Vector{Int}}([1, 2]) isa SizedArray
    @test_throws DimensionMismatch SizedArray{Tuple{2},Int,2,1,Vector{Int}}([1, 2, 3]) isa SizedArray
    @test SizedArray{Tuple{2},Int,2,1,Vector{Int}}(undef) isa SizedArray
    @test SizedArray{Tuple{2,3},Int,2,2,Matrix{Int}}(undef) isa SizedArray

    @test_throws ArgumentError StaticArraysCore.check_array_parameters(Tuple{2.0}, Int, Val{2}, Val{2})
    @test StaticArraysCore.tuple_length((5, 3)) == 2
    @test StaticArraysCore.tuple_prod((5, 3)) == 15
    @test StaticArraysCore.tuple_minimum((5, 3)) == 3
end
