module StaticArraysCore


"""
    abstract type StaticArray{S, T, N} <: AbstractArray{T, N} end
    StaticScalar{T}     = StaticArray{Tuple{}, T, 0}
    StaticVector{N,T}   = StaticArray{Tuple{N}, T, 1}
    StaticMatrix{N,M,T} = StaticArray{Tuple{N,M}, T, 2}

`StaticArray`s are Julia arrays with fixed, known size.

## Dev docs

They must define the following methods:
 - Constructors that accept a flat tuple of data.
 - `getindex()` with an integer (linear indexing) (preferably `@inline` with `@boundscheck`).
 - `Tuple()`, returning the data in a flat Tuple.

It may be useful to implement:

- `similar_type(::Type{MyStaticArray}, ::Type{NewElType}, ::Size{NewSize})`, returning a
  type (or type constructor) that accepts a flat tuple of data.

For mutable containers you may also need to define the following:

 - `setindex!` for a single element (linear indexing).
 - `similar(::Type{MyStaticArray}, ::Type{NewElType}, ::Size{NewSize})`.
 - In some cases, a zero-parameter constructor, `MyStaticArray{...}()` for unintialized data
   is assumed to exist.

(see also `SVector`, `SMatrix`, `SArray`, `MVector`, `MMatrix`, `MArray`, `SizedArray`, `FieldVector`, `FieldMatrix` and `FieldArray`)
"""
abstract type StaticArray{S <: Tuple, T, N} <: AbstractArray{T, N} end
const StaticScalar{T} = StaticArray{Tuple{}, T, 0}
const StaticVector{N, T} = StaticArray{Tuple{N}, T, 1}
const StaticMatrix{N, M, T} = StaticArray{Tuple{N, M}, T, 2}
const StaticVecOrMat{T} = Union{StaticVector{<:Any, T}, StaticMatrix{<:Any, <:Any, T}}

# The ::Tuple variants exist to make sure that anything that calls with a tuple
# instead of a Tuple gets through to the constructor, so the user gets a nice
# error message
Base.@pure tuple_length(T::Type{<:Tuple}) = length(T.parameters)
Base.@pure tuple_length(T::Tuple) = length(T)
Base.@pure tuple_prod(T::Type{<:Tuple}) = length(T.parameters) == 0 ? 1 : *(T.parameters...)
Base.@pure tuple_prod(T::Tuple) = prod(T)
Base.@pure tuple_minimum(T::Type{<:Tuple}) = length(T.parameters) == 0 ? 0 : minimum(tuple(T.parameters...))
Base.@pure tuple_minimum(T::Tuple) = minimum(T)


# Something doesn't match up type wise
function check_array_parameters(Size, T, N, L)
    (!isa(Size, DataType) || (Size.name !== Tuple.name)) && throw(ArgumentError("Static Array parameter Size must be a Tuple type, got $Size"))
    !isa(T, Type) && throw(ArgumentError("Static Array parameter T must be a type, got $T"))
    !isa(N.parameters[1], Int) && throw(ArgumentError("Static Array parameter N must be an integer, got $(N.parameters[1])"))
    !isa(L.parameters[1], Int) && throw(ArgumentError("Static Array parameter L must be an integer, got $(L.parameters[1])"))
    # shouldn't reach here. Anything else should have made it to the function below
    error("Internal error. Please file a bug")
end
@generated function check_array_parameters(::Type{Size}, ::Type{T}, ::Type{Val{N}}, ::Type{Val{L}}) where {Size,T,N,L}
    if !all(x->isa(x, Int), Size.parameters)
        return :(throw(ArgumentError("Static Array parameter Size must be a tuple of Ints (e.g. `SArray{Tuple{3,3}}` or `SMatrix{3,3}`).")))
    end

    if L != tuple_prod(Size) || L < 0 || tuple_minimum(Size) < 0 || tuple_length(Size) != N
        return :(throw(ArgumentError("Size mismatch in Static Array parameters. Got size $Size, dimension $N and length $L.")))
    end

    return nothing
end


"""
    SArray{S, T, N, L}(x::NTuple{L})
    SArray{S, T, N, L}(x1, x2, x3, ...)

Construct a statically-sized array `SArray`. Since this type is immutable, the data must be
provided upon construction and cannot be mutated later. The `S` parameter is a Tuple-type
specifying the dimensions, or size, of the array - such as `Tuple{3,4,5}` for a 3×4×5-sized
array. The `N` parameter is the dimension of the array; the `L` parameter is the `length`
of the array and is always equal to `prod(S)`. Constructors may drop the `L`, `N` and `T`
parameters if they are inferrable from the input (e.g. `L` is always inferrable from `S`).

    SArray{S}(a::Array)

Construct a statically-sized array of dimensions `S` (expressed as a `Tuple{...}`) using
the data from `a`. The `S` parameter is mandatory since the size of `a` is unknown to the
compiler (the element type may optionally also be specified).
"""
struct SArray{S <: Tuple, T, N, L} <: StaticArray{S, T, N}
    data::NTuple{L,T}

    function SArray{S, T, N, L}(x::NTuple{L,T}) where {S<:Tuple, T, N, L}
        check_array_parameters(S, T, Val{N}, Val{L})
        new{S, T, N, L}(x)
    end

    function SArray{S, T, N, L}(x::NTuple{L,Any}) where {S<:Tuple, T, N, L}
        check_array_parameters(S, T, Val{N}, Val{L})
        new{S, T, N, L}(convert_ntuple(T, x))
    end
end

@inline SArray{S,T,N}(x::Tuple) where {S<:Tuple,T,N} = SArray{S,T,N,tuple_prod(S)}(x)


"""
    MArray{S, T, N, L}(undef)
    MArray{S, T, N, L}(x::NTuple{L})
    MArray{S, T, N, L}(x1, x2, x3, ...)


Construct a statically-sized, mutable array `MArray`. The data may optionally be
provided upon construction and can be mutated later. The `S` parameter is a Tuple-type
specifying the dimensions, or size, of the array - such as `Tuple{3,4,5}` for a 3×4×5-sized
array. The `N` parameter is the dimension of the array; the `L` parameter is the `length`
of the array and is always equal to `prod(S)`. Constructors may drop the `L`, `N` and `T`
parameters if they are inferrable from the input (e.g. `L` is always inferrable from `S`).

    MArray{S}(a::Array)

Construct a statically-sized, mutable array of dimensions `S` (expressed as a `Tuple{...}`)
using the data from `a`. The `S` parameter is mandatory since the size of `a` is unknown to
the compiler (the element type may optionally also be specified).
"""
mutable struct MArray{S <: Tuple, T, N, L} <: StaticArray{S, T, N}
    data::NTuple{L,T}

    function MArray{S,T,N,L}(x::NTuple{L,T}) where {S<:Tuple,T,N,L}
        check_array_parameters(S, T, Val{N}, Val{L})
        new{S,T,N,L}(x)
    end

    function MArray{S,T,N,L}(x::NTuple{L,Any}) where {S<:Tuple,T,N,L}
        check_array_parameters(S, T, Val{N}, Val{L})
        new{S,T,N,L}(convert_ntuple(T, x))
    end

    function MArray{S,T,N,L}(::UndefInitializer) where {S<:Tuple,T,N,L}
        check_array_parameters(S, T, Val{N}, Val{L})
        new{S,T,N,L}()
    end
end

@inline MArray{S,T,N}(x::Tuple) where {S<:Tuple,T,N} = MArray{S,T,N,tuple_prod(S)}(x)

@generated function (::Type{MArray{S,T,N}})(::UndefInitializer) where {S,T,N}
    return quote
        $(Expr(:meta, :inline))
        MArray{S, T, N, $(tuple_prod(S))}(undef)
    end
end

@generated function (::Type{MArray{S,T}})(::UndefInitializer) where {S,T}
    return quote
        $(Expr(:meta, :inline))
        MArray{S, T, $(tuple_length(S)), $(tuple_prod(S))}(undef)
    end
end



end # module
