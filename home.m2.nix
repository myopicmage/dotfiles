{ ... }:
{
  home.username = "kevin";
  home.homeDirectory = "/Users/kevin";

  imports = [
    ./home.nix
  ];
}
