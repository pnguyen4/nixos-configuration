let
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "9b10da846ae5f19dfdeb61d2b257e389560890a4";
  }) {};

  iPython = jupyter.kernels.iPythonWith {
    name = "python3";
    packages = p:
      let
        cs202_support = p.buildPythonPackage {
          pname = "cs202_support";
          version = "0.1.0";
          src = builtins.fetchGit {
            url = "https://github.com/jnear/cs202-assignments";
            ref = "master";
            rev = "ffe13750aaa91c4717075ef7d139a77c40ab77dd";
          };
          propagatedBuildInputs = [ p.pandas p.lark-parser ];
        };
      in
        with p; [
          cs202_support
          Keras
          matplotlib
          numpy
          pandas
          pip
          scipy
          scikitlearn
          tensorflow-build_2
        ];
  };

  jupyterEnvironment =
    jupyter.jupyterlabWith {
      kernels = [ iPython ];
    };

in
  jupyterEnvironment.env
