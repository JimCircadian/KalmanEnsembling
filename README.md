# KalmanEnsembling
Using the [model-ensembler][2] alongside the `examples/SinusoidInterface` from [EnsembleKalmanProcesses][1]

## Description

This uses a different tool for ensembling as an naive example to demonstrate HPC based Kalman Filtering.

This example is derived from the code in the original library example for learning parameterisations of a sine wave.

**This is still under development, but the workflow should run from end to end**

### Running

```
python -m venv venv
source venv/bin/activate
pip install --upgrade setuptools pip
pip install -r requirements.txt

# Enter julia REPL
julia
]
instantiate
Ctrl+D
Ctrl+D

# Back in bash
model_ensemble -rt 1 -st 1 -ct 1 -p -v ensemble.yaml dummy
```

## License

This is a derived example from the Julia library and thus the original attribution license is in LICENSE.example, with the workflow being additionally licensed using the Apache 2.0 license, contained under LICENSE.


[1]: https://github.com/CliMA/EnsembleKalmanProcesses.jl
[2]: https://github.com/JimCircadian/model-ensembler
