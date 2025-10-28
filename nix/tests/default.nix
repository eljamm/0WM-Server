{
  pkgs,
  system,
  ngipkgs,
  ...
}:
let
  nixosTest = test: args: pkgs.testers.runNixOSTest (import test args);
in
{
  test = ngipkgs.checks.${system}."projects/0WM/nixos/tests/basic";
  custom-test = nixosTest ./basic.nix { inherit ngipkgs; };
}
