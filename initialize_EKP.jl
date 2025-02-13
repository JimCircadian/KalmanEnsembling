include("shared.jl") # packages

function main()

    output_dir = ARGS[1]
    data_path = joinpath(output_dir, ARGS[2])
    eki_path = joinpath(output_dir, ARGS[3])

    if isfile(eki_path)
        @warn eki_path * " already exists"
        exit(0)
    end

    toml_path = ARGS[4]
    N_ensemble = parse(Int64, ARGS[5])
    rng_seed = parse(Int64, ARGS[6])
    rng_ekp = Random.MersenneTwister(rng_seed)

    # We construct the prior from file
    param_dict = TOML.parsefile(toml_path)
    names = ["initial_thickness"]
    prior_vec = [get_parameter_distribution(param_dict, n) for n in names]
    prior = combine_distributions(prior_vec)

    # we load the data, noise, from file
    @load data_path y Γ

    # initialize ensemble Kalman inversion
    initial_ensemble = EKP.construct_initial_ensemble(rng_ekp, prior, N_ensemble)
    eki = EKP.EnsembleKalmanProcess(initial_ensemble, y, Γ, Inversion(); rng = rng_ekp, localization_method = SEC(3))

    # save the parameter ensemble and EKP
    save_parameter_ensemble(
        get_u_final(eki), # constraints applied when saving
        prior,
        param_dict,
        output_dir,
        "parameters.toml",
        0, # We consider the initial ensemble to be the 0th iteration
    )

    #save new state
    @save eki_path eki param_dict prior


end

main()
