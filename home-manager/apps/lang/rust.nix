
{ config, pkgs, ... }:

{
  # Install Cargo, Rust, and essential build tools
  home.packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    
    pkg-config
    openssl
  ];

  home.sessionVariables = {
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
