"""
TODO: Fill me in
"""
function readmodelfile(path::String)::Dict{String,Any}
    return JSON.parsefile(path)
end