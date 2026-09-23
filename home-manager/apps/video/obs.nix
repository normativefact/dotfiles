{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs                     # Screen capture on wlroots-based compositors
      obs-pipewire-audio-capture # Direct low-latency capture of application audio
      obs-vaapi                  # Hardware encoding for AMD and Intel GPUs
      obs-vkcapture              # Fast Vulkan/OpenGL direct game frame grabber
    ];
  };
}
