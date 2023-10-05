{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin-universal";
        sha256 = "1kghyg9hx2nzn8la67052l17xh1rxh6y7k3pw7id53i4s988l6dy";
      });
      version = "latest";
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
    });
  };
}
