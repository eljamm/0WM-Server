{
  pkgs,
  system,
  ngipkgs,
  ...
}@args:

let
  nixosTest = test: args: pkgs.testers.runNixOSTest (import test args);
in

{
  test = nixosTest ./basic.nix args;
  test-ngipkgs = ngipkgs.checks.${system}."projects/0WM/nixos/tests/basic";
}
