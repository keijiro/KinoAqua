KinoAqua
========

![screenshot](https://i.imgur.com/AqIJD8rl.jpg)

**KinoAqua** is a custom post-processing effect for Unity HDRP that creates a
simple watercolor effect.

The shader implementation of the effect is heavily inspired by
[a Shadertoy effect] created by Florian Berger (flockaroo). It uses the same
approach but with slightly different variables.

[a Shadertoy effect]: https://www.shadertoy.com/view/ltyGRV#

System Requirements
-------------------

- Unity 2019.4 or later

Although KinoAqua is compatible with all the HDRP-supported systems, it's
pretty slow and unoptimized. Don't try to run it on mobiles.

Note that the test project contained in this repository was created using Unity
2021.2. You must install Unity 2012.2.0 (it's still in the alpha phase at the
point I wrote this document) to try the project.

How to install the package
--------------------------

This package uses the [scoped registry] feature to import dependent packages.
Please add the following sections to the package manifest file
(`Packages/manifest.json`).

To the `scopedRegistries` section:

```
{
  "name": "Keijiro",
  "url": "https://registry.npmjs.com",
  "scopes": [ "jp.keijiro" ]
}
```

To the `dependencies` section:

```
"jp.keijiro.kino.aqua": "1.0.1"
```

After changes, the manifest file should look like below:

```
{
  "scopedRegistries": [
    {
      "name": "Keijiro",
      "url": "https://registry.npmjs.com",
      "scopes": [ "jp.keijiro" ]
    }
  ],
  "dependencies": {
    "jp.keijiro.kino.aqua": "1.0.1",
...
```

[scoped registry]: https://docs.unity3d.com/Manual/upm-scoped.html
