{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tenacity   # Privacy-friendly Audacity fork for waveform recording and cleaning
    qpwgraph   # Visual PipeWire patchbay to route mic/desktop streams into recorders
    pavucontrol
  ];
}
