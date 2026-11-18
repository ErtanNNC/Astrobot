# Bölüm 2 · Alan 1: Liman Rıhtımı (Pervane öğretilir). Tasarım: docs/features/bolum-2/design.md
# Çalıştırma: python3 tools/level/ch2_b1_rihtim.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch2_rihtim", "Liman Rıhtımı", "scenes/chapter2/b1_rihtim.tscn", sky="day",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-6, water=-8, seed=21)

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
L.tree(-2.8, 4.0, -80.5, 0.8, fruit=True)
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

# Uzakta fener ve fırtına (sonraki alan)
L.ent("prop", 60, -8, -230, kind="dark_tower", size=2.5)
L.ent("prop", 40, 28, -200, kind="storm", size=4.0)
L.clouds(22, xr=(-100, 100), zr=(-220, 60), avoid=(-20, 20, -140, 20), low=(-6, -3), high=(12, 28))
L.write()
