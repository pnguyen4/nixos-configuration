with import <nixpkgs> {};
with python38Packages;

buildPythonPackage rec {
  pname = "cs202_support";
  version = "0.1.0";
  src = builtins.fetchGit {
    url = "https://github.com/jnear/cs202-assignments";
    ref = "master";
    rev = "ffe13750aaa91c4717075ef7d139a77c40ab77dd";
  };
  propagatedBuildInputs = [ pandas lark-parser ];
}
