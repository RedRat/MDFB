rem Fudgey's Fast/Slow/Video Motion Detector with masks. For models with a separate video button.
rem See MDFB-080914.txt for documentation.
rem Trunk autobuild 509 or higher (or compatible) required.
@title Fast MD 080914

@param a Columns
@default a 6
@param b Rows
@default b 4
@param c Threshold (0-255)
@default c 10
@param g Burst/Review/Video time (s)
@default g 0
@param d Compare Interval (ms)
@default d 7
@param h Pixel Step (pixels)
@default h 6
@param f Channel (0U,1Y,2V,3R,4G,5B)
@default f 1
@param n Timeout (10s of seconds)
@default n 30
@param e Trigger Delay (0.1 sec)
@default e 5
@param i Masking (0=No 1=Mask 2=Use)
@default i 0
@param j -      Mask Columns Left
@default j 0
@param k -      Mask Columns Right
@default k 0
@param l -      Mask Rows    Top
@default l 0
@param m -      Mask Rows    Bottom
@default m 0
@param o Shoot fast=0,slow=1,test=2
@default o 0
@param p Still photo=0, Video=1
@default p 0

if a<1 then a=1
if b<1 then b=1
if i<0 then i=0
if i>2 then i=2
if j<0 then j=0
if k<0 then k=0
if l<0 then l=0
if m<0 then m=0
if j>a then j=a
if k>a then k=a
if l>b then l=b
if m>b then m=b
if g<0 then g=0
if f<0 then f=1
if f>5 then f=1
if f=0 then print "Channel: U chroma"
if f=1 then print "Channel: Luminance"
if f=2 then print "Channel: V chroma"
if f=3 then print "Channel: Red"
if f=4 then print "Channel: Green"
if f=5 then print "Channel: Blue"
if n<1 then n=1
e=e*100
g=g*1000
n=n*10000

P=get_video_button
if P<>1 then goto "VideoButtonError"

P=get_mode
if P=1 then goto "PlayModeError"

P=get_flash_mode
if P=2 then goto "SkipFlashWarning"
  print "WARNING: Flash is not"
  print "disabled. May cause  "
  print "odd behavior.        "
:SkipFlashWarning

if o=0 and p=1 then goto "fast_video_md"
if o=1 and p=1 then goto "slow_video_md"
if o=1 and p=0 then goto "slow_md"
if o=2 then goto "test_md"

print "Fast react photo MD"
:fast_md_loop
  t=0
  do
    release "shoot_half"
    press "shoot_half"
    do
      P=get_shooting
    until P=1
    md_detect_motion a, b, f, n, d, c, 1, t, i, j+1, l+1, a-k, b-m, 9, h, e
  until t>0
  let X=get_tick_count
  :contloop1
    let U=get_tick_count
    let V=(U-X)
    if V<g then goto "contloop1"
  release "shoot_full"  
  release "shoot_half"
  do
    P=get_shooting
  until P<>1
goto "fast_md_loop"

:slow_md
print "Slow react photo MD"
:slow_md_loop
  t=0
  do
    md_detect_motion a, b, f, n, d, c, 1, t, i, j+1, l+1, a-k, b-m, 0, h, e
  until t>0
  if g>0 then goto "contshoot2" else shoot
  goto "slow_md_loop"
  :contshoot2
  press "shoot_full"
  let X=get_tick_count
  :contloop2
    let U=get_tick_count
    let V=(U-X)
    if V<g then goto "contloop2"
  release "shoot_full"
  release "shoot_half"
  do
    P=get_shooting
  until P<>1
goto "slow_md_loop"

rem Models with separate video button can't work in fast mode with video
:fast_video_md
  print "Reverting to"
goto "slow_video_md"

:slow_video_md
if g<1 then g=1000
rem Focusing takes time => add a second to make length argument a bit more accurate.
g=g+1000
print "Slow react video MD"
:slow_video_md_loop
  t=0
  do
    md_detect_motion a, b, f, n, d, c, 1, t, i, j+1, l+1, a-k, b-m, 0, h, e
  until t>0
  click "video"
  print "starting video record"  
  let X=get_tick_count
  :slowvideowaitloop
    let U=get_tick_count
    let V=(U-X)
    if V<g then goto "slowvideowaitloop"
  click "video"
  print "ending video record"
goto "slow_video_md_loop"

:test_md
  print "MD test, no shooting."
  N=0
:test_md_loop
  t=0
  do
    md_detect_motion a, b, f, n, d, c, 1, t, i, j+1, l+1, a-k, b-m, 0, h, e
  until t>0
  N=N+1
  print t, "cells, trigger ", N
goto "test_md_loop"

:PlayModeError
  print "MDFB script ERROR:"
  print "Not in REC mode, exiting."
end

:VideoButtonError
  print "MDFB script ERROR:"
  print "Incompatible camera! Try"
  print "MDFB non-VideoButton version"
  print "instead."
end
