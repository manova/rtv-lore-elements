# RTV-43 ModWorkshop Assets

RTV-43 prepares raw in-game screenshots for the v0.1 ModWorkshop presentation.
The goal is simple release-ready media, not a designed marketing composition.

## Sources

| Asset | Source |
| --- | --- |
| `media/modworkshop_thumb.png` | In-game screenshot `Screenshot 2026-05-03 152241.png` |
| `media/modworkshop_banner.png` | In-game screenshot `Screenshot 2026-05-03 150113.png` |
| `media/mcm_settings.png` | In-game screenshot `Screenshot 2026-05-03 153319.png` |

## Crop choices

The thumbnail source was already a clean Hamina Dispatch reader shot without
the bottom navigation controls. It was center-cropped from `1396x689` to exact
2:1 and resized to `600x300`, preserving the title, AREA 05 stamp, and body
text.

The banner uses the wider lamp source with the most complete lamp silhouette.
It was cropped to a full-width `4236x1059` 4:1 slice and resized to `1000x250`.
The alternate `150312` lamp shot was not used because it clipped the lamp more
aggressively at the right edge.

The MCM screenshot was downscaled from `2668x310` to `1600x186` for README use
while keeping both settings readable.

## Processing

The WSL environment did not allow `sudo` package installation for ImageMagick,
`pngquant`, or `oxipng`, so the assets were generated with a local Pillow
install. PNG output used Pillow's optimized save path. Quality was prioritized
over aggressive file-size reduction because ModWorkshop has previously accepted
larger thumbnails.
