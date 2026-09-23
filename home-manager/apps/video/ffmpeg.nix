{ pkgs, ... }:

let
  # Quick lossless trim script: ff-trim input.mp4 00:01:20 00:02:40 output.mp4
  ffTrim = pkgs.writeShellScriptBin "ff-trim" ''
    if [ "$#" -ne 4 ]; then
      echo "Usage: ff-trim <input> <start_time> <end_time> <output>"
      exit 1
    fi
    ${pkgs.ffmpeg-full}/bin/ffmpeg -ss "$2" -to "$3" -i "$1" -c copy "$4"
  '';

  # Interactive region recorder for Wayland: saves directly to ~/Videos
  recArea = pkgs.writeShellScriptBin "rec-area" ''
    OUT_DIR="''${HOME}/Videos/Recordings"
    mkdir -p "$OUT_DIR"
    FILE="$OUT_DIR/capture_$(date +%Y%m%d_%H%M%S).mp4"
    GEOM=$(${pkgs.slurp}/bin/slurp) || exit 1
    echo "Recording selection to $FILE (Press Ctrl+C to stop)..."
    ${pkgs.wl-screenrec}/bin/wl-screenrec -g "$GEOM" -f "$FILE"
  '';
in
{
  home.packages = with pkgs; [
    ffmpeg-full
    libva-utils      # vainfo (verify VA-API hardware acceleration)
    wl-screenrec     # Ultra-lightweight, hardware-accelerated Wayland screen recorder
    slurp            # Wayland region selection tool
    ffTrim
    recArea
  ];

  # home.shellAliases = {
  #   # Quick audio extraction: ff-audio in.mp4 out.mp3
  #   ff-audio = "ffmpeg -i";
  #   # Fast transcode to WebM/VP9
  #   ff-webm = "ffmpeg -c:v libvpx-vp9 -b:v 0 -crf 30 -c:a libopus";
  # };
}
