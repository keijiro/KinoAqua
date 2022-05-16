KinoAqua
========

![screenshot](https://i.imgur.com/AqIJD8rl.jpg)
![gif](https://i.imgur.com/ZiZ0Avs.gif)

**KinoAqua** is a custom post-processing effect for Unity URP/HDRP that creates
a watercolor effect. The shader implementation of the effect is inspired by
[a Shadertoy effect] created by Florian Berger (flockaroo).

[a Shadertoy effect]: https://www.shadertoy.com/view/ltyGRV#

System Requirements
-------------------

- Unity 2021.3 or later

Note that the shader hasn't been optimized enough for practical use. Although
it's compatible with most of the platforms, it may run significantly slow on
some devices like mobiles.

How to Install
--------------

This package uses the [scoped registry] feature to resolve package
dependencies. Open the Package Manager page in the Project Settings window and
add the following entry to the Scoped Registries list:

- Name: `Keijiro`
- URL: `https://registry.npmjs.com`
- Scope: `jp.keijiro`

![Scoped Registry](https://user-images.githubusercontent.com/343936/162576797-ae39ee00-cb40-4312-aacd-3247077e7fa1.png)

Now you can install the package from My Registries page in the Package Manager
window.

![My Registries](https://user-images.githubusercontent.com/343936/162576825-4a9a443d-62f9-48d3-8a82-a3e80b486f04.png)

[scoped registry]: https://docs.unity3d.com/Manual/upm-scoped.html

How to Use on URP
-----------------

The effect is implemented as a renderer feature on URP. To use the effect, add
the **Aqua Effect Feature** to the renderer feature list.

You also have to add the **Aqua Effect** component to camera objects. You can
control the effect parameters via it, and the effect is only enabled within the
attached camera objects.

[renderer feature]:
  https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@12.0/manual/urp-renderer-feature.html

How to Use on HDRP
------------------

The effect is implemented as a custom post-processing effect on HDRP. To use
the effect, add `Kino.PostProcessing.Aqua` to the Custom Post Process Orders
list in the HDRP Global Settings (you can find the entry in the "After Post
Process" list box).
