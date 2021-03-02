with import <nixpkgs> {};
with python38Packages;

buildPythonPackage rec {
  pname = "cs202_support";
  version = "0.1.0";
  src = builtins.fetchGit {
    url = "https://github.com/jnear/cs202-assignments";
    ref = "master";
    rev = "6340604660fefc134cb84e57b773dcb1bac04e45";
  };
  propagatedBuildInputs = [ pandas lark-parser ];
}
