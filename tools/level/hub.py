# Giriş ekranı + Atölye (oynanabilir ana menü). Tasarım: docs/features/ana-menu/design.md
# Görünüş (2026-11-21): KayKit Restaurant Bits + Furniture Bits (CC0) duvar, kapı, pencere ve mobilyalarıyla
# sıcak bir oda. Görüntü modellerde (MultiMesh, çarpışmasız); çarpışma görünmez kutularda (L.solid).
# Oda x[-10,10] z[-8.5,7.5], duvarlar 8 m (iki sıra 4 m'lik duvar parçası), tavanda ahşap kirişler.
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("hub", "", "scenes/ui/hub.tscn", sky="indoor", music=None, water=None, safe=True,
          root_script="res://scripts/ui/hub.gd", seed=5)
PI = math.pi
R = "kaykit/restaurant/"
F = "kaykit/furniture/"

# ---- Zemin ve dışarısı (pencereden görünen yağmurlu bahçe) ----
L.top(0, 0, -0.5, 20, 16, depth=1.0, theme="floor")
L.box(0, -0.6, -20, 40, 1.0, 22, "grass")
L.kenney("tree", 7, -0.1, -13, 0.4, 3.4); L.kenney("tree-pine", 1, -0.1, -15, 1.2, 3.0)
L.kenney("hedge", 4, -0.1, -10.2, 0, 2.6); L.kenney("flowers", 5.5, -0.1, -10.4, 0.7, 2.4)
L.ent("prop", 4, 8, -15, kind="rain", size=0.8)

# ---- Duvarlar: modeller (iç yüz odaya bakar) + görünmez çarpışma ----
north = ["wall", "wall", "wall_doorway", "wall_window_open", "wall"]
for i, x in enumerate((-8, -4, 0, 4, 8)):
    L.model(R + north[i], x, 0, -8.5, 0)
    L.model(R + "wall", x, 0, 7.5, PI)
for z in (5.5, 1.5, -2.5, -6.5):
    L.model(R + "wall", -10, 0, z, PI / 2)
    L.model(R + "wall", 10, 0, z, -PI / 2)
# üst duvarlar: ahşap kaplama (kulübe/atölye havası)
L.box(0, 6, -8.6, 20.6, 4, 0.5, "wood"); L.box(0, 6, 7.6, 20.6, 4, 0.5, "wood")
L.box(-10.1, 6, -0.5, 0.5, 4, 16.6, "wood"); L.box(10.1, 6, -0.5, 0.5, 4, 16.6, "wood")
for (x, z) in ((-10, -8.5), (10, -8.5), (-10, 7.5), (10, 7.5)):
    L.model(R + "pillar_A", x, 0, z)
# çarpışma: kapı boşluğu kapalı kalır (kapı menü nesnesi, içinden geçilmez)
L.solid(0, 4, -8.5, 20.5, 8, 0.5)
L.solid(0, 4, 7.5, 20.5, 8, 0.5)
L.solid(-10, 4, -0.5, 0.5, 8, 16.5)
L.solid(10, 4, -0.5, 0.5, 8, 16.5)
# tavan kirişleri (ahşap)
for z in (-5.5, -1.5, 2.5, 6.0):
    L.box(0, 7.7, z, 20, 0.45, 0.45, "wood")
L.box(-6, 7.25, -0.5, 0.4, 0.4, 16, "wood"); L.box(6, 7.25, -0.5, 0.4, 0.4, 16, "wood")

L.start(0, 0.35, 1.5, ry=0.0)
L.ent("prop", 0, 0, 1.5, kind="station")
L.model(F + "rug_oval_A", 0, 0.01, 1.5, 0, 1.4)

# ---- Menü nesneleri (yerleri hub.gd ve testlerle uyumlu) ----
L.ent("menu", 0, 0, -8.5, kind="door", action="play")
for i, z in enumerate((-4.5, -1.0, 2.5)):
    L.ent("menu", 7.4, 0, z, ry=-PI / 2, kind="capsule", action="slot", arg=str(i))
L.ent("menu", -7.6, 0, -3.5, ry=PI / 2, kind="tv", action="settings")
L.ent("menu", -7.2, 0, 4.2, ry=PI / 2, kind="showcase", action="collection")
L.ent("menu", 4.5, 0, 6.2, ry=PI, kind="toybox", action="toybox")
L.ent("menu", -4.0, 0, -8.0, kind="switch", action="quit", name="Salter")
for i, a in enumerate(("yay", "balon", "miknatis", "kaya")):
    L.ent("copy", 1.8 + i * 1.6, 0, 4.6, ability=a, groups=["toy"])

# ---- Mobilya ve süsler ----
# Kuzey: tezgâh (atölye masası), raflar, tablo
L.model(F + "table_medium_long", -7.8, 0, -7.3, 0)        # çalışma tezgâhı
L.model(F + "book_set", -8.6, 1.25, -7.4, 0.2); L.model(F + "lamp_table", -6.8, 1.0, -7.6)
L.model(R + "jar_A_large", -7.6, 1.0, -7.0); L.model(R + "jar_C_small", -9.0, 1.0, -6.8)
L.model(F + "chair_stool_wood", -7.6, 0, -5.9)
L.solid(-7.8, 0.5, -7.3, 3.0, 1.0, 2.0)
L.model(F + "shelf_B_large_decorated", -8, 2.9, -8.25, 0)
L.model(F + "pictureframe_large_A", -4, 2.6, -8.25, 0)
L.model(F + "pictureframe_large_B", 8, 2.7, -8.25, 0)
L.ent("menu", 8, 0, -7.6, kind="wardrobe", action="wardrobe")
L.model(F + "lamp_standing", 9.1, 0, -6.2)
# Batı: TV köşesi, kitaplık, koltuk
L.model(F + "cabinet_medium_decorated", -9.2, 0, -0.5, PI / 2)
L.solid(-9.2, 0.9, -0.5, 1.0, 1.8, 2.1)
L.model(F + "pictureframe_medium", -9.75, 2.8, -3.5, PI / 2)
L.model(F + "shelf_B_small_decorated", -9.75, 2.8, 2.2, PI / 2)
L.model(F + "armchair_pillows", -8.4, 0, 6.3, PI * 0.75)
L.solid(-8.4, 0.6, 6.3, 1.6, 1.2, 1.6)
L.model(F + "lamp_standing", -9.1, 0, -6.0)
# Güney: masa, tablolar, kasalar
L.model(F + "pictureframe_small_A", 2.0, 2.6, 7.25, PI)
L.model(F + "pictureframe_large_B", -6.5, 2.7, 7.25, PI)
L.model(R + "crate", 8.6, 0, 6.6, 0.3, 0.75); L.model(R + "crate", 8.6, 0.6, 6.6, 0.9, 0.6)
L.solid(8.6, 0.6, 6.6, 1.6, 1.2, 1.6)
L.model(F + "cactus_medium_A", 6.6, 0, 7.0); L.model(F + "cactus_small_B", -2.0, 0, 7.0)
# Doğu: kapsüllerin arkasında raf
L.model(F + "shelf_B_large_decorated", 9.75, 3.2, -1.0, -PI / 2)
L.model(F + "rug_rectangle_stripes_A", 6.6, 0.01, -1.0, PI / 2, 1.4)

# Dişliler, lambalar, ekran (eski hikâye süsleri)
L.ent("prop", -9.6, 4.8, 0.5, kind="gear", size=1.1, spin=0.5, ry=PI / 2)
L.ent("prop", -9.6, 5.6, -5.0, kind="gear", size=0.7, spin=-0.8, ry=PI / 2)
L.ent("prop", 9.6, 5.2, 5.0, kind="gear", size=0.8, spin=0.7, ry=PI / 2)
for p in ((0, 4.2, -2), (-5, 4.2, 3), (5, 4.2, 3)):
    L.ent("prop", *p, kind="lamp")
L.ent("prop", -2.5, 2.4, 7.2, kind="screen", color=(0.5, 0.9, 0.6, 1), ry=PI)
L.write()
