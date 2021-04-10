with import <nixpkgs> {};
with python38Packages;

buildPythonPackage rec {
  pname = "cs202_support";
  version = "0.1.0";
  src = builtins.fetchGit {
    url = "https://github.com/jnear/cs202-assignments";
    ref = "master";
    rev = "4015d1a1e225ba7eaa32ade4ec264a551e0740b2";
  };
  propagatedBuildInputs = [ pandas lark-parser ];
}
