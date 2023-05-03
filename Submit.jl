# include the include -
include("Include.jl")

# load (and parse) the reaction file -
reaction_data_dictionary = readmodelfile(joinpath(_PATH_TO_DATA,"e_coli_core.json"))

# build the compounds array -
list_of_metabolites = reaction_data_dictionary["metabolites"];
compounds_array = Array{MyChemicalCompoundModel,1}()
for metabolite ∈ list_of_metabolites

    # get the id value -
    id_value = metabolite["id"];
    formula_value = metabolite["formula"];

    # build the compound model -
    compound_model = build(MyChemicalCompoundModel, id_value, formula_value);

    # store -
    push!(compounds_array, compound_model);
end

# build the A matrix model -
atom_matrix_model = build(MyAtomCompoundMatrixModel, compounds_array);

# build the stochiometric matrix model -
stoichiometric_matrix_model = build(MyStoichiometricNetworkMatrixModel, reaction_data_dictionary)
list_of_reation_ids = stoichiometric_matrix_model.reactions;

# Compute Δ = transpose(A)*S
S = stoichiometric_matrix_model.S;
A = atom_matrix_model.A;
Δ = transpose(A)*S

# find index of reactions that are *not* balanced
(number_of_elements, number_of_reactions) = size(Δ);
list_of_unbalanced_reaction_idx = Array{Int,1}();
for i ∈ 1:number_of_reactions
    idx_unbalanced = findall(x->x!=0.0, Δ[:,i]);
    if (isempty(idx_unbalanced) == false)
        push!(list_of_unbalanced_reaction_idx,i)
    end
end

# # build a table -
# N = length(list_of_unbalanced_reactions)
# list_of_reation_ids = stoichiometric_matrix_model.reactions;
# unbalanced_data_table = Array{Any,2}(undef,N,8)
# for i ∈ 1:N
    
#     reaction_id = list_of_reation_ids[i];
#     reaction_index = list_of_unbalanced_reactions[i]
    
#     # set the id, and the index -
#     unbalanced_data_table[i,1] = reaction_id;
#     unbalanced_data_table[i,2] = reaction_index;

#     for j ∈ 1:number_of_elements
#         unbalanced_data_table[i,2+j] = Δ[j,reaction_index]
#     end
# end
# header_labels = ["RID","index","C","H","N","O","P","S"];
# pretty_table(unbalanced_data_table, header=header_labels)

# checks:
compound_dictionary = Dict{String,MyChemicalCompoundModel}()
for model ∈ compounds_array
    key = model.name
    compound_dictionary[key] = model
end
