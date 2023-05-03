# === PRIVATE METHODS BELOW HERE ========================================================================================= #

"""
TODO: Fill me in.
"""
function _build_bounds_array(data::Dict{String,Any})::Array{Float64,2}

    # initialize -
    list_of_reactions = data["reactions"];
    number_of_reactions = length(list_of_reactions)
    bounds_array = Array{Float64,2}(undef,number_of_reactions,2)

    # TODO: fill in the entries of the bounds array, first col is the lower bound, second col is the upper bound
    for i ∈ 1:number_of_reactions
        reaction = list_of_reactions[i];
        L = reaction["lower_bound"];
        U = reaction["upper_bound"];
        bounds_array[i,1] = L
        bounds_array[i,2] = U
    end

    # return -
    return bounds_array
end

"""
TODO: Fill me in.
"""
function _build_reaction_id_array(data::Dict{String,Any})::Array{String,1}
    
    # initialize -
    reaction_id_array = Array{String,1}()

    # TODO: fill the reaction_id_array with the reaction id's from the data dictionary
    reactions = data["reactions"];
    for reaction ∈ reactions
        id_value = reaction["id"]
        push!(reaction_id_array, id_value);
    end
   
    # return -
    return reaction_id_array;
end

"""
TODO: Fill me in.
"""
function _build_metabolite_id_array(data::Dict{String,Any})::Array{String,1}

    # initialize -
    metabolite_id_array = Array{String,1}()

    # TODO: fill the metabolite_id_array with the metabolite id's from the data dictionary
    metabolites = data["metabolites"];
    for metabolite ∈ metabolites
        id_value = metabolite["id"];
        push!(metabolite_id_array, id_value);
    end

    # return -
    return metabolite_id_array;
end

"""
TODO: Fill me in.
"""
function _build_stoichiometric_matrix(data::Dict{String,Any})::Array{Float64,2}
    
    # initialize -
    list_of_metabolites = data["metabolites"];
    list_of_reactions = data["reactions"];
    number_of_reactions = length(list_of_reactions);
    number_of_metabolites = length(list_of_metabolites);
    S = Array{Float64,2}(undef, number_of_metabolites, number_of_reactions);
    
    # TODO: fill in the entries of the stochiometric matrix
    # fill w/zeros -
    fill!(S,0.0);

    # build the stochiometric matrix -
    for i ∈ 1:number_of_metabolites
        
        # get a metabolite -
        metabolite_id = list_of_metabolites[i]["id"]
        
        for j ∈ 1:number_of_reactions

            # grab the reaction object, and then metabolites dictionary -
            metabolite_dictionary = list_of_reactions[j]["metabolites"]
            if (haskey(metabolite_dictionary, metabolite_id) == true)
                S[i,j] = metabolite_dictionary[metabolite_id];
            end
        end
    end

    # return -
    return S
end

"""
TODO: Fill me in
"""
function _build_composition_dictionary(compound::String)::Dict{Char,Float64}
    return recursive_compound_parser(compound);
end

"""
TODO: Fill me in
"""
function _build_atom_matrix(compounds::Array{MyChemicalCompoundModel,1})::Array{Float64,2}

    # initialize -
    number_of_atoms = 6 # we are going to balance on {C,H,N,O,P,S}
    number_of_compounds = length(compounds);
    atom_matrix = Array{Float64,2}(undef, number_of_compounds, number_of_atoms);

    # TODO: Fill in the elements of the atom_matrix -
    elements = ['C','H','N','O','P','S'];
    for i ∈ 1:number_of_compounds
        
        # get the compound model -
        compound_model = compounds[i];
        composition_dictionary = compound_model.composition;
        
        # check the atoms -
        for j ∈ 1:number_of_atoms
            
            # get the element -
            element = elements[j];
            if (haskey(composition_dictionary, element) == true)
                value = composition_dictionary[element];
                atom_matrix[i,j] = value;
            else
                atom_matrix[i,j] = 0.0;
            end
        end
    end

    # return -
    return atom_matrix;
end

# ======================================================================================================================== #

# === PUBLIC METHODS BELOW HERE ========================================================================================== #

"""
    build(type::Type{MyChemicalCompoundModel}, name::String, compound::String)::MyChemicalCompoundModel

Factory method to build an instance of the MyChemicalCompoundModel type. MyChemicalCompoundModel is a model of the
information contained in the JSON model file
"""
function build(type::Type{MyChemicalCompoundModel}, name::String, compound::String)::MyChemicalCompoundModel

    # check: name, reactants and products correct?
    # in production, we'd check this. Assume these are ok now

    # initialize -
    model = MyChemicalCompoundModel(); # build an empty model 

    # add data to the model -
    model.name = name;
    model.compound = compound;
    model.composition = _build_composition_dictionary(compound);

    # return -
    return model;
end

"""
    build(type::Type{MyStoichiometricNetworkMatrixModel}, data::Dict{String,Any}) -> MyStoichiometricNetworkMatrixModel
"""
function build(type::Type{MyStoichiometricNetworkMatrixModel}, 
    data::Dict{String,Any})::MyStoichiometricNetworkMatrixModel

    # build an empty instance of our model -
    model = MyStoichiometricNetworkMatrixModel();

    # construct model elements -
    model.species = _build_metabolite_id_array(data);
    model.reactions = _build_reaction_id_array(data);
    model.bounds = _build_bounds_array(data);
    model.S = _build_stoichiometric_matrix(data);

    # return -
    return model;
end

"""
    build(type::Type{MyAtomCompoundMatrixModel}, compounds::Array{MyChemicalCompoundModel,1}) -> MyAtomCompoundMatrixModel
"""
function build(type::Type{MyAtomCompoundMatrixModel}, 
    compounds::Array{MyChemicalCompoundModel,1})::MyAtomCompoundMatrixModel

    # build an empty atom model -
    model = MyAtomCompoundMatrixModel();

    # construct the model elements, add them to the model -
    model.compounds = compounds;
    model.A = _build_atom_matrix(compounds);

    # return -
    return model;
end
# ======================================================================================================================== #