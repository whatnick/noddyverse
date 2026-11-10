# noddyverse 

## With the closure of Cloustor, which stored the Noddyverse files, direct  programmatic access to the Noddyverse is unfortunately not possible at the moment. Happilly you can download the entire model suite once again thanks to the support of the Australian National Computational Infrastructure.   [NCI Storage Link](https://thredds.nci.org.au/thredds/catalog/catalogs/tm64/noddyverse/noddyverse.html) Sept/2024



 [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/Loop3D/noddyverse/HEAD?filepath=noddyverse-remote-files-1M.ipynb) <<--not working!!


C Code to generate random Noddy models, together with example notebook to visualise randomly selected models from 1M model suite:

       
The notebook randomly samples and displays models from the 1 Million model suite, with the possibility to filter to specific deformation event sequences. 
   
For each model the magnetic response, the gravity response, the top surface, the north facing vertical section (looking from the south) and the west-facing vertical section (looking from the west) of the 4 x 4 x 4 km cube are displayed: 
   
![Example output](images/example.png)
   
The models consist of 20 m cubic voxels (200x200x200 voxels per model), and the history file used to define each model is provided as a link for each model. Windows software to read this history file is available at the <a href="http://tectonique.net/noddy">Noddy Site</a>, and the source code for a command line version of Noddy, as well as this notebook, is available here. The 1M models themselves *were* stored at  Cloudstor as individual files and as 343 tar files, one per history sequence but this service has now closed, and an alternative solution is currently being sought</a>.
   




## FM4G fork: seeded, static, multi-arch Noddy image

This fork (`whatnick/noddyverse`, branch `fm4g/seeded-block-image`) adds a small,
**default-off** patch to `src/RandomNoddy.c` and a container build, for generating
reproducible Noddyverse-distribution blocks at scale (CSIRO FM4G / EASI).

**Image:** `ghcr.io/whatnick/noddyverse` — static Noddy CLI (Alpine/musl build,
runs in any Linux image), `linux/amd64` + `linux/arm64`, ~2.5 MB (busybox base).

```bash
docker run --rm -v $PWD:/w -w /w ghcr.io/whatnick/noddyverse:fm4g-v1 model.his out BLOCK
# copy the binary into another image (e.g. a Kubernetes init container):
#   cp /usr/local/bin/noddy /tools/noddy
```

**RANDOM-mode environment variables** (all optional; unset = original behaviour):

| Variable | Effect |
|---|---|
| `NODDY_SEED` | seed the xoroshiro128+ generator (default: wall clock) → identical history per seed, on every architecture |
| `NODDY_CUBE` | geology/geophysics cube size in m over the 4 km Noddyverse cube (default 20 → 200³; 250 → 16³) |
| `NODDY_HIS_ONLY` | write the history and stop (skip the 200³ block + anomaly render); render it with `noddy <his> <out> BLOCK` |
| `NODDY_MIN_DYKE_W` | clamp dyke width to ≥ this (m) — avoids sub-voxel dykes at coarse cubes; RNG stream unchanged |
| `NODDY_MIN_LAYER_H` | clamp each stratigraphic layer increment to ≥ this (m); RNG stream unchanged |

Kinematic geology is scale-free, so a 4 km model rendered at `NODDY_CUBE=250` (16³) is
exactly the Noddyverse distribution rescaled to a 16³ block; it agrees with the 200³
render at 99.6 % of the 16³ cell centres (seed 7). CI pins `NODDY_SEED=7 NODDY_CUBE=250`
to a known block hash on both architectures. Output layers in `.g12` run top → bottom,
and rock codes with density / susceptibility are listed in `.g00`. History files differ
across runs only in the `#Filename` / `#Date Saved` header lines.
