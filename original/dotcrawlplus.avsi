#avisynth

#######################################
## Avisynth dot crawl effect (make your video ugly on purpose)
# http://forum.doom9.org/showthread.php?t=170433
#@ raffriff42, 2014-04-03
#######################################

## SEE ALSO:
## ScanLines
##     http://avisynth.nl/index.php/Scanlines
## CRT emulation with scanline and phosphor effects - cretindesalpes
##     http://forum.doom9.org/showthread.php?p=1683051

/*
http://www.doom9.org/index.html?/capture/chroma_artefacts.html

Rainbow effects and dot crawls are caused by imperfect separation of the luma and
chroma components of a composite video signal. This effect is called <<color
crosstalk.>> It is most noticeable on computer generated images like subtitles,
weather maps, stationary logos and video images where you have hi-frequency data
(like the shot of a skyscraper in the distance).

Whenever you have strong alternating, fine patterns (= high frequencies) in luma,
you have <<rainbow effects>>. Whenever you have a sudden, big change in chroma
(typically computer generated graphics etc.), you have <<dot crawls>>.

The technical terms are as follows:
    "rainbow"   is cross color (hi-frequency luma data upsets the chroma demodulator)
    "dot crawl" is cross luminance (chroma leftovers in the Y signal).

*/


## PLUGINS:

## from a global .avsi script, auto-loaded:
#global pathBase = "<path>\AviSynth 2.6\plugins-NOT\" 

# http://manao4.free.fr/mt_masktools.html
LoadPlugin(pathBase + "MaskTools2\mt_masktools-26.dll")

# http://avisynth.org.ru/docs/english/externalfilters/addgrain.htm
# http://forum.doom9.org/showthread.php?t=111849
LoadPlugin(pathBase + "QTGMC_Plugins\AddGrainC.dll")

# http://avisynth.org.ru/fft3dfilter/fft3dfilter.html
LoadPlugin(pathBase + "fft3dfilter211\FFT3DFilter.dll")


### TABLE OF CONTENTS ###
#--------------
#@function dotcrawlpreset(clip C, string "preset",
##\            float "dots", float "rainbow", 
##\            bool "showpreset", bool "showargs")
#--------------
#@function dotcrawlplus2(clip C, int "dotstyle",
##\            float "dotblend", float "dotscale", int "dotleak", 
##\            int "csub", float "cblur", float "lblur",
##\            int "lnoise", int "cnoise", float "streaking",
##\            float "rainbow", bool "showargs")
#--------------
#@function dpc_makedotcrawl(clip T, int "size")
#@function dpc_makedots(clip T, float "offset", int "size")
#@function dpc_makerainbow(clip C, float "chroma")
#@function dpc_uumidpass(clip C, 
##\   int "tlo", int "thi", bool "setupmode")
#@function dpc_uuhipass(clip C, int "tlo", int "thi", bool "setupmode") 
#@function dpc_histostretch(clip C, 
##\   float "thresh_lo", float "thresh_hi", float "gamma", bool "show")
#@function stack_to_size(clip C, int wid, int hgt)  
#@function stack_to_wid(clip C, int wid, clip "R") 
#@function stack_to_hgt(clip C, int hgt, clip "R") 
#@function convert_to_Y8(clip C) 
#@function convert_to_YV24(clip C) 
#--------------
#@function StrReplace(string base, string findstr, string repstr)
#@function f2cuv(float f) 
#@function _uumod(int m, float f, bool "z")
#@function StrinF(float f)
#@function UUGaussianBlurYV12(clip C, float "varY", float "varC", 
##\                       float "radY", float "radC", 
##\                       string "show")
#@function UUGaussianBlurY(clip C, float "var", float "rad")
#@function UUSize2(clip C, int wid, int hgt)
#--------------
#@function gridmask_square(clip C, int size)
#@function gridmask_diag(clip C, int size)
#--------------

#######################################
### emulate NTSC dot crawl & analog video cassette recorder noise
##
## @ preset - choices:
##            "mild"     - minimal effect
##            "medium"   - softer chroma; a little added noise
##            "heavy"    - very soft & noisy
##            "strong"   - like medium but more so
##            "bigdot1"  - larger dots #1
##            "bigdot2"  - larger dots #2
##            "bigdot3"  - larger dots #3
##            empty string ("") defaults to "medium";
##            unrecognized values raise an error.
## @ dots     - dotcrawl effect amount
##                 (default depends on preset)
## @ rainbow   - rainbow effect amount
##                 (default depends on preset)
## @ showpreset - if true, show the preset name as a Subtitle
##                 (default false)
## @ showargs  - if true, show the arguments as a Subtitle
##                 (default false)
##
function dotcrawlpreset(clip C, string "preset",
\            float "dots", float "rainbow", 
\            bool "showpreset", bool "showargs")
{
    preset      = Default(preset, "")
    dots        = Default(dots,
    \                 (preset=="bigdot3") ? 0.7
    \               : (preset=="bigdot2") ? 0.7
    \               : (preset=="bigdot1") ? 0.7
    \               : (preset=="heavy")   ? 1.0
    \               : (preset=="strong")  ? 1.0
    \               : (preset=="mild")    ? 0.7
    \               : 0.7)
    dots        = Float(Min(Max(0, dots), 1))
    rainbow     = Default(rainbow,
    \                 (preset=="bigdot3") ? 0.3
    \               : (preset=="bigdot2") ? 0.3
    \               : (preset=="bigdot1") ? 0.3
    \               : (preset=="heavy")   ? 1.0
    \               : (preset=="strong")  ? 0.6
    \               : (preset=="mild")    ? 0.3
    \               : 0.4)
    rb          = Float(Min(Max(0, rainbow), 1))
    showpreset  = Default(showpreset, false)
    showargs    = Default(showargs,   false)

    C ## Last
    R = (preset=="bigdot3")
    \     ? dotcrawlplus2(dotstyle=2,
    \          dotblend=dots, dotscale=3, dotleak=0, 
    \          csub=1, cblur=0.0, lblur=0.0,
    \          lnoise=0, cnoise=0, streaking=0,
    \          rainbow=rb, showargs=showargs)
    \ : (preset=="bigdot2")
    \     ? dotcrawlplus2(dotstyle=2,
    \          dotblend=dots, dotscale=2, dotleak=0, 
    \          csub=1, cblur=0.0, lblur=0.0,
    \          lnoise=0, cnoise=0, streaking=0,
    \          rainbow=rb, showargs=showargs)
    \ : (preset=="bigdot1")
    \     ? dotcrawlplus2(dotstyle=2,
    \          dotblend=dots, dotscale=1.5, dotleak=0, 
    \          csub=1, cblur=0.0, lblur=0.0,
    \          lnoise=0, cnoise=0, streaking=0,
    \          rainbow=rb, showargs=showargs)
    \ : (preset=="heavy")
    \     ? dotcrawlplus2(dotstyle=0,
    \          dotblend=dots, dotscale=2, dotleak=32, 
    \          csub=4, cblur=1.0, lblur=0.5,
    \          lnoise=22, cnoise=32, streaking=1,
    \          rainbow=rb, showargs=showargs)
    \ : (preset=="strong")
    \     ? dotcrawlplus2(dotstyle=1,
    \          dotblend=dots, dotscale=1.5, dotleak=24, 
    \          csub=4, cblur=0.5, lblur=0.0,
    \          lnoise=4, cnoise=4, streaking=0,
    \          rainbow=rb, showargs=showargs)
    \ : (preset=="mild")
    \     ? dotcrawlplus2(dotstyle=0,
    \          dotblend=dots, dotscale=1, dotleak=0, 
    \          csub=1, cblur=0.0, lblur=0.0,
    \          lnoise=0, cnoise=0, streaking=0,
    \          rainbow=rb, showargs=showargs)
    \ : (preset=="medium" || preset=="")
    \     ? dotcrawlplus2(dotstyle=0,
    \          dotblend=dots, dotscale=1, dotleak=0, 
    \          csub=2, cblur=0.0, lblur=0.0,
    \          lnoise=2, cnoise=4, streaking=0,
    \          rainbow=rb, showargs=showargs)
    \ : Assert(false, "dotcrawlplus2: unrecognized preset")

    return (showpreset==false) ? R
    \  : R.Subtitle(preset, x=-1, y=Round(0.7*C.Height),
    \       size=C.Height/8, text_color=$66c0c0c0, halo_color=$66000000)
}

#######################################
### emulate NTSC dot crawl & analog video cassette recorder noise
##
## @ dotstyle  - dots style (0..2; default 0)
## @ dotblend  - dots opacity (default 1.0)
## @ dotscale  - scale of dot crawl (1..4; default 1; >2 is ugly)
## @ dotleak   - allow some dot crawl everywhere 
##                 (0-255; default 0; 32 is just visble; >64 is extreme)
## @ csub      - default 2 (1=betacam; 2=VHS)
## @ cblur     - default 0.3 (0.0=no added blur; 0.5=VHS)
## @ lblur     - default 0.3
## @ lnoise    - default 4 (0=bypass; 2=subliminal; 22-33=VHS)
## @ cnoise    - default 4 (0=bypass; 2=subliminal; 33=VHS)
## @ streaking - default 0.0 (1.0=extreme horizontal streaking)
## @ rainbow   - rainbow effect opacity (default 0.2)
## @ showargs  - if true, show the arguments as a Subtitle
##
## @version 1.3 05-Apr-2014 raffriff42 (compatible w/ AVS 2.58)
## @version 1.4 06-Apr-2014 raffriff42 (rainbow)
## @version 2.0 09-Apr-2014 raffriff42 (internal dot generator)
## @version 2.1 12-Apr-2014 raffriff42 (improved rainbow)
##
function dotcrawlplus2(clip C, int "dotstyle",
\            float "dotblend", float "dotscale", int "dotleak", 
\            int "csub", float "cblur", float "lblur",
\            int "lnoise", int "cnoise", float "streaking",
\            float "rainbow", bool "showargs")
{
    Assert(IsClip(C) && IsYV12(C),
    \   "dotcrawlplus2: clip 'C' must be YV12")
    Assert((C.Width % 8)==0 && (C.Height % 8)==0,
    \   "dotcrawlplus2: clip 'C' resolution is not mod-8")

    dotstyle  =       Min(Max(0, Default(dotstyle,  0)),   2)
    dotblend  = Float(Min(Max(0, Default(dotblend,  1)),   1))
    dotleak   =       Min(Max(0, Default(dotleak,   0)),   255)
    dotscale  = Float(Min(Max(1, Default(dotscale,  1)),   4))
    csub      =       Min(Max(1, Default(csub,      2)),   4)
    cblur     = Float(Min(Max(0, Default(cblur,     0.3)), 1))
    lblur     = Float(Min(Max(0, Default(lblur,     0.3)), 1))
    lnoise    =       Min(Max(0, Default(lnoise,    4)),   64)
    cnoise    =       Min(Max(0, Default(cnoise,    4)),   64)
    streaking = Float(Min(Max(0, Default(streaking, 0)),   1))
    rainbow   = Float(Min(Max(0, Default(rainbow,   0.2)), 1))
    showargs  =                  Default(showargs,  false)

    C = (showargs==false) ? C : C.Subtitle(
    \     " dotblend="   + StrinF(dotblend)
    \ + "\n dotleak="    + String(dotleak)
    \ + "\n dotscale="   + StrinF(dotscale)
    \ + "\n csub="       + String(csub)
    \ + "\n cblur="      + StrinF(cblur)
    \ + "\n lblur="      + StrinF(lblur)
    \ + "\n lnoise="     + String(lnoise)
    \ + "\n cnoise="     + String(cnoise)
    \ + "\n streaking="  + StrinF(streaking)
    \ + "\n rainbow="    + StrinF(rainbow) ,
    \ lsp=0, align=4, x=-1, y=-1,
    \ text_color=$ccffffff, halo_color=$cc000000)

    ## soften & add noise ########################
    C ## Last
    Tweak(hue=33) ## IQ translation: I to V, Q to U

    ## US, VS : U & V, subsampled

    sh = Min(0.8 * csub / 2.0, streaking)
    sv =  (0.125 * csub / 2.0)
    US = UtoY.BilinearResize(_uumod(2, 0.5*Width/csub), Height/csub)
    \       .AddGrain(cnoise, hcorr=sh, vcorr=sv)
    VS = VtoY.BilinearResize(_uumod(2, 1.0*Width/csub), Height/csub)
    \       .AddGrain(cnoise, hcorr=sh, vcorr=sv)
    Y = Grayscale
    \       .AddGrain(lnoise, hcorr=0.25, vcorr=0.125)
    \       .convert_to_Y8()

    US = (cblur<0.01) ? US : US.Blur(cblur)
    VS = (cblur<0.01) ? VS : VS.Blur(cblur)
    Y  = (lblur<0.01) ? Y  : Y.Blur(lblur)

    US = US.BilinearResize(Width/2, Height/2)
    VS = VS.BilinearResize(Width/2, Height/2)
#return US.Grayscale()

    ## chroma transition edge masks ##############

    mdots2 = (dotscale>2)

    #emode="laplace" ## (least sensitive)
    #emode="roberts"
    emode="cartoon"
    #emode="sobel"
    #emode="min/max"
    #emode="prewitt" ## (most sensitive)

    ## 'EU' = 'edge mask, U channel'
    EU = US.mt_edge(mode=emode).convert_to_Y8()
    
    ## 'EV' = 'edge mask, V channel'
    EV = VS.mt_edge(mode=emode).convert_to_Y8()

    EU2 = (mdots2==false) ? EU
    \  : EU.mt_expand.mt_expand.Blur(1.0)
    EV2 = (mdots2==false) ? EV
    \  : EV.mt_expand.mt_expand.Blur(1.0)
#return StackHorizontal(StackVertical(EU,EU2),StackVertical(EV,EV2)).Grayscale()

    ## 'EC' = 'edge mask, color'
    EC = mt_logic(EU2, EV2, "max")
    EC = (dotleak==0) ? EC
    \ : EC.Levels(32, 1.0, 235, dotleak, 255, coring=false)
    EC = EC.BilinearResize(Width, Height)
#return EC.Grayscale()

    YToUV(US, VS, Y)
    Tweak(hue=-33) ## reverse IQ translation above

    ## dot crawl #################################

    dotcrawl = dpc_makedotcrawl(2)
    dotcrawl = (Abs(1.0-dotscale)<0.3) ? dotcrawl 
    \  : dotcrawl.BilinearResize(
    \       _uumod(2, dotscale*dotcrawl.Width), 
    \       _uumod(2, dotscale*dotcrawl.Height))
    dotcrawl = dotcrawl.UUSize2(EC.Width, EC.Height) 
#return dotcrawl
    dotmask = EC.mt_logic(dotcrawl, "min")
#return dotmask.Grayscale()

    dotoffset = ((dotscale>1.5) ? 2 : 1)
    dotmode   = (dotstyle==0) ? "luma" : "blend"  

    dotclip = (dotstyle==1) ? Overlay(Last, x=dotoffset, y=dotoffset)
    \       : (dotstyle==2) ? Overlay(Tweak(bright=20, sat=0.5), x=1, y=1)
    \       : Tweak(bright=20, sat=0.3)

    Overlay(dotclip, mask=dotmask, mode=dotmode, opacity=dotblend)

    ## rainbow ###################################

    ## 'RC' = 'Rainbow Clip'
    RC = dpc_makerainbow()

    ## 'RM' = 'Rainbow Mask'
    RM = dpc_uumidpass()
    RM = (csub<2)         ? RM : RM.mt_expand().Blur(1)
    RM = RM.Levels(0, 0.2, 220, 0, 255, coring=false).Grayscale()

    ## 'RY' = 'Rainbow Luma' 
    ##   (without it, rainbow is missing @ white areas)
    RY = RC.ConvertToRGB32().ShowGreen("YV12")
#return RC 
#return RM

    ## final assembly ############################

    showmask = false
    return (showmask)  ? C.Overlay(dotmask.GrayScale(), opacity=0.5)
    \ : (rainbow<0.01) ? Last
    \ : Last.Overlay(RC, mask=RM, mode="chroma", opacity=rainbow)
    \       .Overlay(RY, mask=RM, mode="luma", opacity=Min(0.4*rainbow, 0.1))
}

##################################
### generate a moving dot crawl
##
## @ C    - "template" clip (size, frame rate etc) minimum size 512x512
## @ size - 1-4 (default 2)
##
## @ returns moving dots clip
##
function dpc_makedotcrawl(clip T, int "size")
{
    size = Default(size, 2)
    size = (size==1) ? 2
    \    : (size==2) ? 3
    \    : (size==3) ? 4
    \    : (size==4) ? 5
    \    : Assert(false, "dpc_makedotcrawl: invalid 'size' argument")

    T ## Last
    Crop(0, 0,
    \  _uumod(8, Min(Height, size*4), false),
    \  _uumod(8, Min(Width, size*4), false))
    global gdots00 = dpc_makedots(0.00, size)
    global gdots25 = dpc_makedots(0.25, size)
    global gdots50 = dpc_makedots(0.50, size)
    global gdots75 = dpc_makedots(0.75, size)

    ## slow crawl (min size=2)
    ScriptClip(Last.ConvertToYV24(), """
        ConditionalSelect(Last, "current_frame % 4", 
        \ gdots00, gdots25, gdots50, gdots75)
     """)

    SeparateFields.SelectEvery(2, 1).AssumeFrameBased()
    SeparateFields.SelectEvery(2, 1).AssumeFrameBased()
    Crop(0, 0, Height*2, 0)
    Spline16Resize(Width/2, Height)

    size = (size==2) ? 2
    \    : (size==3) ? 4
    \    : (size==4) ? 8
    \    : (size==5) ? 16
    \    : 1
    Crop(0, 0, 
    \  (Width<=size)?0:(-Width % size), 
    \  (Height<=size)?0:(-Height % size))

    stack_to_size(T.Width, T.Height)
    return Last
}

##################################
### generate a dot pattern
##
## @ C      - "template" clip (size, frame rate etc)
## @ offset - 0 to 1
## @ size   - 1-5 (default 2)
##
function dpc_makedots(clip T, float "offset", int "size")
{
    Assert(IsClip(T) && HasVideo(T),
    \   "dpc_makedots: clip 'T' invalid")

    offset = Float(Min(Max(0, Default(offset, 0)), 1))
    size = Default(size, 2)
    size = (size==1) ? 1
    \    : (size==2) ? 2
    \    : (size==3) ? 4
    \    : (size==4) ? 8
    \    : (size==5) ? 16
    \    : Assert(false, "dpc_makedots: invalid 'size' argument")
    off_i = Round(offset * 2.0 * size)

    T = T.ConvertToYV12().Loop()
    R = mt_logic(
    \      mt_lutspa(T, mode="absolute", chroma="128",
    \         expr=("""((((y/(2*$s))%2)>0) ? cos((x/$s)*pi) : -1*(cos((x/$s)*pi)))*108+126""")
    \              .StrReplace("$s", String(size)).mt_polish),
    \      mt_lutspa(T, mode="absolute", chroma="128",
    \        expr=("cos((y/$s)*pi)*108+126")
    \             .StrReplace("$s", String(size)).mt_polish),
    \      "andn")

    R = R.ConvertToYV24()
    R = (off_i==0) ? R
    \ : StackHorizontal(
    \       R.Crop(0, 0, -R.Width % size, 0),
    \       R)
    R = ((R.Width-off_i)<T.Width) ? R : R.Crop(off_i, 0, T.Width, 0)

    return R
    #\ ._dbgmsg("offset="+StrinF(offset)+";  off_i="+String(off_i))
}

##################################
### generate a rainbow pattern
##
## @ sat    - chroma intensity (default 1.0)
## @ xluma  - ratio of clip cross-luma to fixed pattern (0..1; default 0.75)
## 
function dpc_makerainbow(clip C, float "sat", float "xluma")
{
    sat  = Float(Default(sat, 1))
    xluma = Float(Min(Max(0, Default(xluma, 0.75)), 1))
    
    Y  = C.ConvertToY8()
    YB = Y.UUGaussianBlurYV12(radY=3).ConvertToY8()
    YH = Y.Subtract(YB)
    \     .mt_lut(("(x<$lo)?($lo):((x>$hi)?($hi):(x))")
    \           .StrReplace("$lo", String(128-8))
    \           .StrReplace("$hi", String(128+8))
    \           .mt_polish())
    \     .ConvertToRGB32()

    H1 = YH.GeneralConvolution(128, """
             2 0 0 
             0 0 0 
             0 0 -2 """).ConvertToYV12()
    H2 = YH.GeneralConvolution(128, """
            -2 0 0 
             0 0 0 
             0 0 2 """).ConvertToYV12()

    slh = ("x 1 $o - * y $o * + ").StrReplace("$o", String(xluma))

    U = mt_lutspa(C, mode="absolute", 
    \     expr="x 64 / y -32 / + pi * cos -48 * 126 + ", chroma="128")
    U = mt_lutxy(U, H1, slh, U=-128, V=-128) 
    
    V = mt_lutspa(C, mode="absolute", 
    \     expr="x 72 / y -36 / + pi * sin 64 * 126 + ", chroma="128")
    V = mt_lutxy(V, H2, slh, U=-128, V=-128) 
    
    return YToUV(U, V, Y).ConvertToYV12()
    \  .ColorYUV(cont_y=f2cuv(0), cont_u=f2cuv(sat), cont_v=f2cuv(sat))
    #\ .Crop(0, 0, -256, 0).Histogram(mode="levels")
}

##################################
### "mid pass"
function dpc_uumidpass(
\   clip C, int "tlo", int "thi", bool "setupmode")
{
    tlo    = Default(tlo, 128)
    thi    = Default(thi, 148)
    setupmode = Default(setupmode, false)

    CG = C.Grayscale()
    Last = CG
    Blur(1, 1)
    FFT3DFilter(bt=1, bw=64, bh=64, ow=32, oh=32,
    \  sigma=0, sigma2=0, sigma3=500, sigma4=100000)
    Subtract(UUGaussianBlurY(rad=1))
    mt_expand()
    Grayscale()
    return (setupmode) 
    \ ? dpc_histostretch(50.0, 0.01, 1.8, true)
    \ : Levels(tlo, 1.8, thi, 0, 255, coring=false)
}

##################################
### DEAD
function dpc_uuhipass(clip C, int "tlo", int "thi", bool "setupmode") 
{
    tlo    = Default(tlo, 128)
    thi    = Default(thi, 255)
    setupmode = Default(setupmode, false)

    Last = C.UUHipass(unblur=0.1, sharp=0.5, cont=1, gray=true, show="")
    mt_expand()
    Grayscale()
    return (setupmode) 
    \ ? dpc_histostretch(50.0, 0.01, 1.8, true)
    \ : Levels(tlo, 1.8, thi, 0, 255, coring=false)
}

##################################
### auto dynamic histogram stretch 
function dpc_histostretch(
\   clip C, float "thresh_lo", float "thresh_hi", float "gamma", bool "show")
{
    thresh_lo = Float(Default(thresh_lo, 0))
    thresh_hi = Float(Default(thresh_hi, 0))
    gamma     = Float(Default(gamma,     1))
    show      = Default(show, false)

    return (show==false) 
    \ ? ScriptClip(C, ("""
    \     lo=YPlaneMin($tlo)
    \     hi=YPlaneMax($thi)
    \     Levels(lo, $gam, hi, 0, 255, coring=false)
    \ """)
    \   .StrReplace("$tlo", String(thresh_lo))
    \   .StrReplace("$thi", String(thresh_hi))
    \   .StrReplace("$gam", String(gamma))
    \ )
    \ : ScriptClip(C, ("""
    \     lo=YPlaneMin($tlo)
    \     hi=YPlaneMax($thi)
    \     hgt=Height/16
    \     Levels(lo, $gam, hi, 0, 255, coring=false)
    \     Subtitle("lo($tlo)="+String(lo)+"\nhi($thi)="+String(hi), 
    \      size=hgt, text_color=$808080, x=-1, y=hgt, lsp=2*hgt)
    \ """)
    \   .StrReplace("$tlo", String(thresh_lo, "%0.2f"))
    \   .StrReplace("$thi", String(thresh_hi, "%0.2f"))
    \   .StrReplace("$gam", String(gamma))
    \ )
}

##############################
## Stack clip 'C' until it is at least 'wid' wide
function stack_to_size(clip C, int wid, int hgt)  {
    C ## Last
    stack_to_wid(wid)
    stack_to_hgt(hgt)
    Crop(0, 0, wid, hgt)
    return Last
}

##############################
## Stack clip 'C' horizontally until it is at least 'wid' wide
function stack_to_wid(clip C, int wid, clip "R") {
    R = Default(R, C)
    return (R.Width >= wid) ? R
    \  : stack_to_wid(C, wid, StackHorizontal(R, C))
}

##############################
## Stack clip 'C' vertically until it is at least 'hgt' high
function stack_to_hgt(clip C, int hgt, clip "R") {
    R = Default(R, C)
    return (R.Height >= hgt) ? R
    \  : stack_to_hgt(C, hgt, StackVertical(R, C))
}

##################################
function convert_to_Y8(clip C) {
## hackish workaround for avs 2.58
## for use within this script only
    try {
        return C.ConvertToY8()
    } catch (e) {
        return C.ConvertToYV12().Tweak(sat=0)
    }
}

##################################
function convert_to_YV24(clip C) {
## hackish workaround for avs 2.58
## for use within this script only
    try {
        return C.ConvertToYV24()
    } catch (e) {
        return C.ConvertToRGB24()
    }
}

/*__END__*/
#################### library routines: ####################

# http://avisynth.nl/index.php/HDColorBars
##################################
##
function StrReplace(string base, string findstr, string repstr)
{
    pos = FindStr(base, findstr)
    return (StrLen(findstr)==0) || (pos==0)
    \   ? base
    \   : StrReplace(
    \       LeftStr(base, pos-1) + repstr +
    \       MidStr(base, pos+StrLen(findstr)),
    \       findstr, repstr)
}

#######################################
### transform "normal" float arguments to
### ColorYUV's "gain_x", "gamma_x" & "cont_x" scale
##
function f2cuv(float f) {
    return Round((f - 1.0) * 256.0)
}

##################################
## return argument 'f' as integer and ensure it is Mod 'm'
##
## @ m - mod value
## @ f - input (may be positive or negative)
## @ z - always mod towards zero after rounding (default true)
##
## Examples:
##     _uumod(2,  3.4) ==  2
##     _uumod(2,  3.6) ==  4
##     _uumod(2, -3.4) == -2
##     _uumod(2, -3.6) == -4
##
##     _uumod(2,  3)        ==  2
##     _uumod(2,  3, false) ==  4
##     _uumod(2, -3)        == -2
##     _uumod(2, -3, false) == -4
##
function _uumod(int m, float f, bool "z")
{
    m = Max(1, m)
    mult = Default(z, true) ? -1 : 1
    fsgn = Sign(f)
    i = Round(Abs(f))
    return fsgn * Max(0, i + mult * (i % m))
}

#######################################
## format a Float as a String with 2 decimals
function StrinF(float f)
{
    return String(f, "%0.2f")
}

##################################
### emulate GaussianBlur (YV12 only version)
##
## @ varY - works like GaussianBlur (default=1.5)
## @ varC - works like GaussianBlur (default=varY)
## @ radY - blur radius (varY squared); overrides varY
## @ radC - blur radius (varC squared); overrides varC
## @ show - ("Y"|"U"|"V"|"") (default="" - all channels)
##
## @version 1.0 raffriff42 23-Oct-2013
##
function UUGaussianBlurYV12(
\    clip C, float "varY", float "varC", 
\    float "radY", float "radC", 
\    string "show")
{
    varY    = Max(0.0, Float(Default(varY, 1.5 )))
    radY    = Float(Default(radY, Pow(varY, 0.5)))
    varY    = Pow(Min(Max(0.0, radY), 256.0), 2.0)
    
    varC    = Max(0.0, Float(Default(varC, varY)))
    radC    = Float(Default(radC, Pow(varC, 0.5)))
    varC    = Pow(Min(Max(0.0, radC), 256.0), 2.0)
    
    show = Default(show, "")

    B = (C.IsYV24) ? C : C.ConvertToYV24() 

    U = B.UToY8.UUGaussianBlurY(varC)
    V = B.VToY8.UUGaussianBlurY(varC)
    Y = B.ConvertToY8.UUGaussianBlurY(varY) 
    B = YToUV(U, V, Y)

    R = (StrCmpi(show,"Y")==0)   ? Y 
    \ : (StrCmpi(show,"U")==0)   ? U
    \ : (StrCmpi(show,"V")==0)   ? V
    \ : (varY<0.003 && varC<0.003) ? C
    \ : (varY==varC) ? C.UUGaussianBlurY(varY) 
    \ : B
    return R.ConvertToYV12()
}

##################################
### emulate GaussianBlur - simplified version,
##  does not care about source color model
##
## @ var - works like GaussianBlur's varY
## @ rad - works like most "normal" GaussianBlurs
##
## @version 1.1 raffriff42 23-Oct-2013
##
function UUGaussianBlurY(clip C, float "var", float "rad")
{
    var = Max(0.0, Float(Default(var, 1.0)))
    rad = Max(1.0, Float(Default(rad, Pow(var, 0.5))))
    var = Pow(Min(Max(0.0, rad), 60.0), 2.0)
    
    w0 = C.Width
    h0 = C.Height
    w1 = Round(w0/rad)
    h1 = Round(h0/rad) /* formerly "w0/rad" ?? */

    B = C.BilinearResize(
    \         Min(Max(12, w1 + (w1 % 2)), w0), 
    \         Min(Max(12, h1 + (h1 % 2)), h0))

    B = B.Blur(1.0).Blur(1.0)
    
    return (var<0.01) ? C 
    \    : (var<1.5)  ? C.Blur(0.85 * var)
    \    : (B.Width>8 && B.Height>8) ? B.GaussResize(w0, h0)
    \    : B.BilinearResize(w0, h0)
}

##################################
### crop or add border to ensure clip is a certain size
#
#@param pan  - -1=left, 0=center, 1=right; [default = 0]
#@param tilt - -1=up,   0=center, 1=down;  [default = 0]
#
function UUSize2(clip C, int wid, int hgt, float "pan", float "tilt")
{
    isrgb = (C.IsRGB24 || C.IsRGB32) 

    bdrWid = (wid - C.Width)
    bdrHgt = (hgt - C.Height)

    xctr  = Min(Max(-1.0, Float(Default(pan, 0.0))), 1.0) 
    yctr  = Min(Max(-1.0, Float(Default(tilt, 0.0))), 1.0) 

    bdrLt = Abs(Round(Float(bdrWid) / 2.0))
    bdrLt = bdrLt + Round(bdrLt * xctr)
    bdrLt = Sign(bdrWid) * (bdrLt + (isrgb ? 0 : (bdrLt % 2)))
    
    bdrTp = Abs(Round(Float(bdrHgt) / 2.0)) 
    bdrTp = bdrTp + Round(bdrTp * yctr)
    bdrTp = Sign(bdrHgt) * (bdrTp + (isrgb ? 0 : (bdrTp % 2)))
    
    bdrRt = (bdrWid - bdrLt) 
    bdrBt = (bdrHgt - bdrTp)

    C = C.AddBorders(
          \ ((bdrLt > 0) ? bdrLt : 0), 
          \ ((bdrTp > 0) ? bdrTp : 0), 
          \ ((bdrRt > 0) ? bdrRt : 0), 
          \ ((bdrBt > 0) ? bdrBt : 0))

    C = C.Crop(
          \ ((bdrLt < 0) ? -bdrLt : 0), 
          \ ((bdrTp < 0) ? -bdrTp : 0), 
          \ ((bdrRt < 0) ?  bdrRt : wid), 
          \ ((bdrBt < 0) ?  bdrBt : hgt))

    return C
}

#######################################
## Not used in dotcrawlplus, but a related function:
## create a fixed pattern of dots.
function gridmask_square(clip C, int size)
{
    C
    return mt_logic(
    \   mt_lutspa(mode="absolute", chroma="-128",
    \             expr=("""cos(x / $s * pi) * 108 + 126""")
    \               .StrReplace("$s", String(size))
    \               .mt_polish ),
    \   mt_lutspa(mode="absolute", chroma="-128",
    \             expr=("cos(y / $s * pi) * 108 + 126")
    \               .StrReplace("$s", String(size))
    \               .mt_polish ),
    \  "andn")
}

#######################################
## Not used in dotcrawlplus, but a related function:
## create a fixed pattern of dots.
function gridmask_diag(clip C, int size)
{
    C
    return mt_logic(
    \  mt_lutspa(mode="absolute", chroma="-128",
    \     expr=("""(cos(x / $s * pi) * ((y / 2 * $s % 2) > 0) ? 1 : -1) * 108 + 126""")
    \          .StrReplace("$s", String(size)).mt_polish),
    \  mt_lutspa(mode="absolute", chroma="-128",
    \    expr=("cos(y / $s * pi) * 108 + 126")
    \         .StrReplace("$s", String(size)).mt_polish),
    \  "andn")
}



