docker run -it \
   -e XDG_RUNTIME_DIR=/tmp \
   -e WAYLAND_DISPLAY=wayland-0 \
   -v /run/user/$(id -u)/wayland-0:/tmp/wayland-0 \
   --user=$(id -u):$(id -g) \
   <image_name> <wayland_application>



   docker run -ti --rm \
   -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   firefox
