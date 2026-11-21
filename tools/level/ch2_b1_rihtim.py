# Bölüm 2 · Alan 1: Liman Rıhtımı (Pervane öğretilir). Tasarım: docs/features/bolum-2/design.md
# Çalıştırma: python3 tools/level/ch2_b1_rihtim.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch2_rihtim", "Liman Rıhtımı", "scenes/chapter2/b1_rihtim.tscn", sky="day",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-6, water=-8, seed=21)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -18, -35), (0, -77, 45)])

PI = math.pi

# ---------- Öğret: başlangıç rıhtımı, Pervane kaynağı, yüksek iskele ----------
L.top(0, 0, -1, 12, 18, depth=8, theme="wood")              # x[-6,6] z[8,-10]
L.start(0, 0.1, 5, ry=PI)
L.ent("copy", 0, 0, -3, ability="pervane")
L.ent("hint", 0, 0, -3, hint="ability", size=(6, 3, 5))
L.ent("hint", 0, 0, -8, hint="hold_jump", size=(10, 3, 4))
L.guide(0, 1.8, -3)
L.battery_line((0, 0, 3), (0, 0, 0), 3)
for x in (-5.2, 5.2):                                         # babalar
    L.box(x, 0.5, 6, 0.6, 1.0, 0.6, "stone")
    L.box(x, 0.5, -9, 0.6, 1.0, 0.6, "stone")
L.deco("chest", -4.4, 0, 6.5, 0.9, ry=0.3)
L.ent("crate", 4.5, 0, 2, batteries=3)
L.ent("crate", 4.5, 1.0, 2, batteries=2)
L.ent("crate", -4.6, 0, -1, batteries=2)
L.deco("pipe", -5.5, 0.5, -6, 0.8, ry=PI / 2)
# Yüksek iskele (5,5 m): yalnızca Pervane ile (Yay 5 m'de kalır)
L.top(0, 5.5, -18, 8, 8, depth=14, theme="wood")              # z[-14,-22]
L.battery_line((0, 1.5, -10.5), (0, 6.5, -13.2), 4)
L.label(0, 7.6, -14.5, "5,5 m")
L.guide(0, 7.5, -16)
L.ent("checkpoint", -2.5, 5.5, -19, checkpoint_id="iskele", ry=PI)
L.deco("flag", 3.2, 5.5, -21, 1.0)
L.ent("crate", 2.8, 5.5, -16, batteries=3)

# ---------- Sına: deniz üstü sallanan iskeleler ----------
L.ent("platform", 0, 5.25, -29, kind="move", size=(3.5, 0.5, 3.5), offset=(5, 0, 0), duration=2.4, color=(0.8, 0.55, 0.32))
L.battery_ring((0, 5.5, -29), 1.2, 4, y=0.6)
L.ent("platform", 2.5, 5.25, -38, kind="move", size=(3.5, 0.5, 3.5), offset=(-5, 0, 0), duration=2.8, color=(0.8, 0.55, 0.32))
L.top(0, 4.5, -47, 7, 6, depth=13, theme="wood")              # ara rıhtım z[-44,-50]
L.battery_arc((0, 5.5, -33), (0, 4.5, -44), 5, 2.0)
L.ent("enemy", 0, 4.5, -47, kind="zipzip", batteries=3)
L.guide(0, 6.5, -47)

# ---------- Şaşırt: martıların (Zıpzıp) üstünden atılma, kaybolan dalga platformları ----------
for i, (x, y) in enumerate(((-2.0, 3.5), (2.0, 3.0), (-1.5, 3.5))):
    z = -56 - i * 6
    L.ent("platform", x, y - 0.25, z, kind="fall", size=(3, 0.5, 3), color=(0.45, 0.7, 1.0))
    L.battery(x, y, z)
L.ent("enemy", 4.5, 4.5, -60, kind="zipzip", batteries=2)  # su üstünde zıplayan martı (kendi adacığında)
L.top(4.5, 4.5, -60, 2.5, 2.5, depth=2, theme="stone")
L.top(0, 4.0, -77, 8, 8, depth=12, theme="sand")              # orta ada z[-73,-81]
L.ent("checkpoint", -2.5, 4.0, -78, checkpoint_id="ada", ry=PI)
L.tree(-2.2, 4.0, -79.6, 0.8, fruit=True)
L.bush(2.6, 4.0, -80.3, 0.8)
L.grass_patch(-3.5, 3.5, -80.5, -74, 4.0, 8, avoid=[(-1.5, 1.5, -81, -73)])
L.ent("copy", 2.4, 4.0, -75.5, ability="pervane")             # kaybedene yedek

# Gizli Altın Vida: adanın yanında havada asılı tabla (yalnızca Pervane ile)
L.top(-7.3, 9.0, -77, 2.4, 2.4, depth=0.4, theme="wood")
L.ent("screw", -7.3, 9.1, -77)


# ---------- Ustalık: uzun deniz geçişi (yükselme + atılma + yeniden yükselme) ----------
L.top(0, 3.0, -88, 3.5, 3.5, depth=1, theme="blue")           # boşluk ~5,3 m (gerekli ≈ %70)
L.top(0, 6.0, -97, 3.5, 3.5, depth=1, theme="red")            # 3 m yukarı + ~5,5 m
L.top(0, 2.5, -106.5, 3.5, 3.5, depth=1, theme="blue")
L.battery_arc((0, 4.0, -81), (0, 3.0, -88), 4, 2.5)
L.battery_arc((0, 3.0, -88), (0, 6.0, -97), 4, 4.0)
L.battery_arc((0, 6.0, -97), (0, 2.5, -106.5), 4, 3.0)
L.ent("enemy", 0, 6.0, -97, kind="zipzip", batteries=2)
L.guide(0, 8, -97)
# Varış rıhtımı
L.top(0, 3.5, -119, 12, 14, depth=12, theme="wood")           # z[-112,-126]
L.ent("checkpoint", -3.5, 3.5, -115, checkpoint_id="varis", ry=PI)
L.ent("crate", 4, 3.5, -116, batteries=3)
L.ent("exit", 0, 3.5, -122)
L.deco("flag", -4.5, 3.5, -124, 1.0)
L.deco("bridge", 4.5, 3.5, -124, 0.8, ry=0.0)
for x in (-5.5, 5.5):
    L.box(x, 4.0, -113, 0.6, 1.0, 0.6, "stone")

# =====================================================================================
# Liman kasabası ve deniz yaşamı (KayKit Medieval Hexagon + Quaternius Animated Fish, CC0)
# =====================================================================================
MD = "kaykit/medieval/"


def md(model, x, y, z, ry=0.0, s=5.0):
    L.model(MD + model, x, y, z, ry, s)


# Batıda kıyı kasabası: kara şeridi, evler, değirmen, pazar (oynanış dışı manzara)
L.top(-29, -3.0, -10, 22, 64, depth=8, theme="grass2", side="stone")     # z[22,-42]: yol -25,5'te doğuya döner
L.top(-33, -1.0, -10, 14, 64, depth=2, theme="grass")
for i, (m, z) in enumerate((("building_home_A_blue", 6), ("building_tavern_yellow", -10), ("building_home_B_red", -26),
                             ("building_market_green", -38), ("building_watermill_blue", 16), ("building_windmill_red", -18))):
    md(m, -24.5 if i % 2 == 0 else -29, -3.0, z, PI / 2 + (i % 3) * 0.3, 6.0)
for z in range(18, -40, -9):
    L.kenney(random.choice(("tree", "tree-pine")), -36, -1.0, z + random.uniform(-3, 3), random.uniform(0, 6.28), 3.2)
md("mountain_A_grass_trees", -55, 0, -40, 0.4, 14); md("hills_A_trees", -50, 0, -110, 1.2, 14)
# Rıhtım eşyaları: varil, kasa, çuval, palet
for (x, y, z) in ((-4.6, 0, 3.5), (-5.0, 0, 2.6), (4.8, 0, -6.5), (2.6, 5.5, -20.6), (-2.6, 4.5, -45.2), (4.5, 3.5, -113.5)):
    md(random.choice(("barrel", "crate_A_big", "sack", "crate_B_small")), x, y, z, random.uniform(0, 6.28), 5.0)
md("pallet", -4.2, 0, -5.8, 0.2, 5.0); md("crate_long_A", 3.4, 0, 6.4, 1.6, 5.0)
md("wheelbarrow", -4.0, 3.5, -117.5, 0.8, 5.0); md("bucket_water", 3.0, 4.0, -79.2, 0, 5.0)
# Ahşap kazıklar (iskele ayakları) suya iner
for (x, z) in ((-5.6, 7.5), (5.6, 7.5), (-5.6, -9.5), (5.6, -9.5), (-3.6, -21.5), (3.6, -21.5), (-3.2, -49.5), (3.2, -49.5)):
    L.box(x, -4.5, z, 0.5, 8, 0.5, "wood")
# Yunuslar ve balina
for (x, z, sc) in ((9, -30, 1.0), (-8, -62, 0.9), (8, -92, 1.0), (-9, -104, 0.8), (14, 5, 1.1)):
    L.ent("prop", x, -8, z, kind="dolphin", size=sc, parent="Decor")
L.ent("prop", 45, -8.5, -80, kind="whale", size=2.0, parent="Decor")
# Yön işareti: uzakta Fener (sonraki alan) adası
L.top(30, -2, -175, 18, 18, depth=8, theme="sand", side="stone")
md("building_tower_A_red", 30, -2, -175, 0, 9.0)
L.ent("prop", 30, 18, -175, kind="lamp", size=3.0)

# --- Gizli köşe: direk tepesi (iskelenin doğusunda, Pervane ile) ---
L.box(8, 2.3, -18, 0.6, 16.6, 0.6, "wood")
L.top(8.2, 11.0, -18, 3.6, 3.6, depth=0.4, theme="wood")
L.ent("crate", 9.1, 11.0, -19.1, batteries=5)
L.battery_ring((8, 11.0, -18), 1.0, 6)
md("flag_red", 8.6, 11.0, -17.2, 0, 5.0)

# Uzakta fener ve fırtına (sonraki alan)
L.ent("prop", 60, -8, -230, kind="dark_tower", size=2.5)
L.ent("prop", 40, 28, -200, kind="storm", size=4.0)
L.clouds(22, xr=(-100, 100), zr=(-220, 60), avoid=(-20, 20, -140, 20), low=(-6, -3), high=(12, 28))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("direk", 8.2, 11, -18, 3.6, 3.6)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.setpiece("whale", 0, 4.0, -80, (0, -7, -90), size=(10, 5, 3), big=1.5)
L.write()
