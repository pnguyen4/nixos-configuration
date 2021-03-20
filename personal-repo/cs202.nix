with import <nixpkgs> {};
with python38Packages;

buildPythonPackage rec {
  pname = "cs202_support";
  version = "0.1.0";
  src = builtins.fetchGit {
    url = "https://github.com/jnear/cs202-assignments";
    ref = "master";
    rev = "5901954c31437d5c1373797f787f2466755b09a1";
  };
  propagatedBuildInputs = [ pandas lark-parser ];
}
