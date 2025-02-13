# Now, we define a model which generates a sinusoid given parameters ``\theta``: an
# amplitude and a vertical shift. The model adds a random phase shift upon evaluation.
using WAVI, Interpolations


# We then define ``G(\theta)``, which returns the observables of the sinusoid
# given a parameter vector. These observables should be defined such that they
# are informative about the parameters we wish to estimate. Here, the two
# observables are the ``y`` range of the curve (which is informative about its
# amplitude), as well as its mean (which is informative about its vertical shift).
function parameter_to_data_map(ensemble_parameters)
    simulation = driver(ensemble_parameters)
    surface_elevation = simulation.model.fields.gh.s[:]
    return surface_elevation
end

function driver(ensemble_parameters)

    #
    #Grid and boundary conditions
    #
    nx = 40
    ny = 5
    nσ = 4
    x0 = 0.0
    y0 = -40000.0
    dx = 16000.0
    dy = 16000.0
    h_mask=trues(nx,ny)
    u_iszero = falses(nx+1,ny); u_iszero[1,:].=true
    v_iszero=falses(nx,ny+1); v_iszero[:,1].=true; v_iszero[:,end].=true
    grid = Grid(nx = nx, 
                ny = ny,   
                nσ = nσ, 
                x0 = x0, 
                y0 = y0, 
                dx = dx, 
                dy = dy,
                h_mask = h_mask, 
                u_iszero = u_iszero, 
                v_iszero = v_iszero)
    
    #
    #Bed 
    #
    function modified_mismip_plus_bed(x,y)
        xbar = 300000.0
        b0 = -200.0; b2 = -728.8; b4 = 343.91; b6 = -50.75*0.95;
        wc = 24000.0; fc = 4000.0; dc = 500.0
        bx(x)=b0+b2*(x/xbar)^2+b4*(x/xbar)^4+b6*(x/xbar)^6
        by(y)= dc*( (1+exp(-2(y-wc)/fc))^(-1) + (1+exp(2(y+wc)/fc))^(-1) )
        b = max(bx(x) + by(y), -720.0)
        return b
    end
    bed = modified_mismip_plus_bed;
    
    
    #
    #solver parameters
    #
    maxiter_picard = 1
    solver_params = SolverParams(maxiter_picard = maxiter_picard)
    
    #
    #Physical parameters
    #
    #default_thickness = ensemble_parameters["initial_thickness"] #set the initial condition this way
    #accumulation_rate = 0.3
    #params = Params(default_thickness = default_thickness, 
    #                accumulation_rate = accumulation_rate)


    accumulation_rate = 0.3
    params = Params(accumulation_rate = accumulation_rate)

    xsamp = 0.0:640000.0:640000.0
    ysamp = -40000.0:80000.0:40000.0
    hsamp = ensemble_parameters["initial_thickness"]
    li = linear_interpolation((xsamp,ysamp),reshape(hsamp,2,2))
    initial_thickness = li.(grid.xxh,grid.yyh) #set the initial condition this way
    initial_conditions = InitialConditions(initial_thickness = initial_thickness)
    
    #
    #make the model
    #
    model = Model(grid = grid,
                  bed_elevation = bed, 
                  params = params, 
                  solver_params = solver_params,
                  initial_conditions = initial_conditions)
    
    #
    #timestepping parameters
    #
    niter0 = 0
    dt = 1.0
    end_time = 100.0

    timestepping_params = TimesteppingParams(niter0 = niter0, 
                                             dt = dt, 
                                             end_time = end_time)
    

    #
    # assemble the simulation
    #
    simulation = Simulation(model = model, 
                            timestepping_params = timestepping_params)
                    
    #
    #perform the simulation
    #
    run_simulation!(simulation)
    
    return simulation

end
    
