# balls_videos_generator

Creates the frames of a video of moving balls for a neuroscience experiment

The capture now also outputs a final `frame_answer.png` frame: after every black screen frame
has been recorded, the overlay is removed without advancing the simulation, and the
ball positions are captured once more in that reveal image.


Execute the .exe (or equivalent on platforms other than Windows) with the `config.txt` file next to it.
It shall create videos following the `config.txt` data, including per-ball properties such as:

## Configuration file reference

Place a `config.txt` next to the executable (or in `export/` when running from the editor). Each line uses the
`key = value` format; empty lines and `#` comments are ignored. Defaults listed below are applied when a key is
missing.

- `fps` (int, default `60`): Frame rate used for both physics and video capture.
- `duration_seconds` (float, default `10`): Total duration of the capture in seconds.
- `arena_size` (int, default `800`): Size (pixels) of the square arena; balls bounce when reaching its edges.
- `black_screen_start` (float, default `duration_seconds - 2`): Time in seconds when the black screen overlay
  appears; leave empty to use the default.
- `ball_count` (int, default `1`): Number of balls to spawn.
- `ball_radii` (comma-separated floats): Radius per ball. If omitted, `ball_radius` is used for every ball.
- `ball_radius` (float, default `20.0`): Fallback radius when `ball_radii` is not provided.
- `ball_colors` (comma-separated hex colors, default `#ffffff`): Color per ball; values repeat if fewer than
  `ball_count` entries are provided.
- `ball_positions` (semicolon-separated `x,y` pairs, default `100,100`): Spawn position per ball; entries repeat
  when fewer than `ball_count` are defined.
- `ball_directions` (semicolon-separated `x,y` vectors, default `1,0`): Initial direction per ball. Vectors are
  normalized internally before multiplying by speed.
- `ball_speeds` (comma-separated floats, default `100`): Speed per ball in pixels per second.
- `ball_masses` (comma-separated floats): Mass per ball; if omitted, `ball_mass` is used for every ball.
- `ball_mass` (float, default `1.0`): Fallback mass when `ball_masses` is not provided.
- `ball_frictions` (comma-separated floats): Friction factor per ball. Positive values slow the ball down over time,
  negative values accelerate it.
- `ball_friction` (float, default `0.0`): Fallback friction when `ball_frictions` is not provided.

Example `config.txt`:

```
fps = 60
duration_seconds = 12
arena_size = 1024
black_screen_start = 10
ball_count = 3
ball_radii = 15,20,25
ball_colors = #ff0000,#00ff00,#0000ff
ball_positions = 100,100; 200,200; 300,300
ball_directions = 1,0; 0,1; -1,0
ball_speeds = 120,140,160
ball_masses = 1.0,2.0,1.5
ball_frictions = 0.0,15.0,-5.0
```

## Converting recorded frames to a video with ffmpeg

When the project records frames as individual images, you can stitch them into a video using ffmpeg. Place all
exported images in a single folder with a consistent filename pattern (for example, `frame_00001.png`). Then run
one of the following commands from that folder:

- Create an MP4 video from numbered PNG files at 60 fps:
  ```bash
  ffmpeg -framerate 60 -i "frame_%05d.png" -c:v libx264 -pix_fmt yuv420p output.mp4
  ```

- Create a lossless WebM video while preserving alpha transparency:
  ```bash
  ffmpeg -framerate 60 -i "frame_%05d.png" -c:v libvpx-vp9 -lossless 1 -pix_fmt yuva420p output.webm
  ```

Adjust `-framerate` to match the `fps` used in your `config.txt`, and update the `frame_%05d.png` pattern if your
files use a different prefix or padding.
