#!/bin/bash
# Mağaza ekran görüntüleri (1920×1080, afişsiz) → build/magaza/. Kullanım: GODOT=/yol/godot tools/store/make_shots.sh
# Konumlar tasarım koordinatıdır (x,y,z,yön); tests/_shot_area.gd köşeli alanlarda kendisi çevirir.
cd "$(dirname "$0")/../.."
G=${GODOT:-godot}
OUT=$PWD/build/magaza; mkdir -p "$OUT"
shot(){ SCENE=$1 SPOTS="$2" SHOT_DIR=$OUT PREFIX=$3 STORE=1 timeout 200 xvfb-run -a -s "-screen 0 1920x1080x24" \
  "$G" --path . --rendering-driver opengl3 --resolution 1920x1080 tests/_shot_area.tscn 2>&1 | grep "SCRIPT ERROR"; }
shot res://scenes/chapter1/a1_yay_bahcesi.tscn "0,0.1,5,3.14" 01_yay_bahcesi &
shot res://scenes/chapter1/a2_balon_kanyonu.tscn "-3,22.1,-137,3.14" 02_balon_kanyonu &
shot res://scenes/chapter1/a3_miknatis_fabrikasi.tscn "0,0.1,4,3.14" 03_miknatis_fabrikasi &
shot res://scenes/chapter2/b1_rihtim.tscn "0,0.1,5,3.14" 04_liman &
wait
shot res://scenes/chapter3/c2_donmus_gol.tscn "0,6.1,-124,3.14" 05_donmus_gol &
shot res://scenes/chapter4/d1_bulut_basamaklari.tscn "0,7.6,-68,3.14" 06_bulut &
shot res://scenes/chapter5/e1_oyuncak_kasabasi.tscn "0,0.1,4,3.14" 07_oyuncak &
shot res://scenes/chapter5/e3_volkan_adasi.tscn "0,0.1,-4.5,3.14" 08_volkan &
wait
ls "$OUT"
