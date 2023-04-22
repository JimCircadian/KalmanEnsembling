include("shared.jl") # packages

function main()
    eki_path = ARGS[1]

    # load current state 
    @load eki_path eki param_dict prior
    N_ensemble = eki.N_ens
    dim_output = size(eki.obs_mean)[1]

    # align to observe_sinusoid.jl
    dt = 0.01
    trange = 0:dt:(2 * pi + dt)
    theta_true = [1.0, 7.0]

    plot(trange, theta_true..., c = :black, label = "Truth", legend = :bottomright, linewidth = 2)
    plot!(
        trange,
        [model(get_ϕ(prior, ensemble_kalman_process, 1)[:, i]...) for i in 1:N_ensemble],
         c = :red,
         label = ["Initial ensemble" "" "" "" ""],
    )
    plot!(trange, [model(final_ensemble[:, i]...) for i in 1:N_ensemble], c = :blue, label = ["Final ensemble" "" "" "" ""])

    xlabel!("Time")
end

main()
