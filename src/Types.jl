abstract type AbstractChemicalCompoundModel end

"""
    MyChemicalCompoundModel

Holds data for the chemical compound records
"""
mutable struct MyChemicalCompoundModel <: AbstractChemicalCompoundModel

    # data -
    name::String
    compound::String
    composition::Dict{Char,Float64}

    # constuctor
    MyChemicalCompoundModel() = new()
end

"""
TODO: Fill me in
"""
mutable struct MyStoichiometricNetworkMatrixModel

    # data -
    S::Array{Float64,2}
    bounds::Array{Float64,2}
    species::Array{String,1}
    reactions::Array{String,1}

    # constructor -
    MyStoichiometricNetworkMatrixModel() = new()
end

"""
TODO: Fill me in
"""
mutable struct MyAtomCompoundMatrixModel

    # data -
    A::Array{Float64,2}
    compounds::Array{MyChemicalCompoundModel,1}

    # constructor -
    MyAtomCompoundMatrixModel() = new()
end