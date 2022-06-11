# DotCrawlPlus
Avisynth dot crawl effect (make your video ugly on purpose)
*(by raffriff42)*

This is a archive/mirror of an AviSynth .avsi plugin, originally uploaded on DropBox and posted on doom9 on 3rd April 2014, 21:57 *(GMT -3:00)*.

The maintainer of this archive already made a modern fork of the original script called [DotCrawl++](https://github.com/rgm89git/DotCrawlPlusPlus).

## Gallery

<img src="https://github.com/rgm89git/dotcrawlplus/blob/main/images/dotcrawlplus-sw-01b-mild.jpg?raw=true" height="350">
<img src="https://github.com/rgm89git/dotcrawlplus/blob/main/images/frafs-testpatt-01e-heavy.jpg?raw=true" height="350">

## Requisites

- **AviSynth**
    - [AviSynth 2.6](http://sourceforge.net/projects/avisynth2/) or lower *(for the original script)*
    - [AviSynth+](https://github.com/AviSynth/AviSynthPlus/releases) *(for the AVS+ port)*
- **Plugins** *(need to be added onto the plugins folder on the AviSynth program folder)*
    - [MaskTools](https://github.com/pinterf/masktools/releases/)
    - [AddGrainC](https://github.com/pinterf/AddGrainC/releases)
    - [FFT3DFilter](https://github.com/pinterf/fft3dfilter/releases) *(need FFTW 3.3.5 dlls)*

## Navigation

- :file_folder: [images](https://github.com/rgm89git/dotcrawlplus/tree/main/images)
    - **Example images**
- :file_folder: [original](https://github.com/rgm89git/dotcrawlplus/tree/main/original)
    - **[dotcrawlplus](https://github.com/rgm89git/dotcrawlplus/blob/main/original/dotcrawlplus.avsi)** *(Original version)*
    - **[dotcrawlplus2_avsplus](https://github.com/rgm89git/dotcrawlplus/blob/main/original/dotcrawlplus2_avsplus.avsi)** *(poisondeathray's AVS+ port)*

## Original description
*(from [the original doom9 thread](https://forum.doom9.org/showthread.php?t=170433))*

Inspired by recently reading the [Avisynth gone wrong](http://forum.doom9.org/showthread.php?t=144861) thread here, and spurred on by a question on another forum (Betacam/betacam Sp Effect For Virtualdub?), I give you **dotcrawlplus**, an Avisynth dot crawl effect. For convenience, it can blur the chroma and add noise at the same time. There's a wrapper function with a few named presets, or you can set all the options directly.

It's not terribly elegant. I'm sure the effect could be refined. It's intended for use as a quick special effect for a music video or whatnot; it's not a very good composite video emulator. You are not going to fool an expert with it. (I suggest a hardware solution for a perfect emulation)
