# Bölüm 4 · Alan 2: Kıvılcım Kalesi. Tasarım: docs/features/bolum-4/design.md
# Metal surlara Mıknatısla tırmanış, testereler ve dikenler, Kaya ile ağır kapılar (biri zamanlı),
# Buz ile dondurulan Hurda Goblin merdiveni, sonunda altı yeteneği sırayla isteyen final parkuru.
# Çalıştırma: python3 tools/level/ch4_d2_kivilcim_kalesi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch4_kale", "Kıvılcım Kalesi", "scenes/chapter4/d2_kivilcim_kalesi.tscn", sky="storm",
          kill_height=-8, water=None, seed=42)


def wall(x0, x1, z0, z1, top, bottom, theme="stone"):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


# ---------- Avlu ve metal sur (Mıknatıs) ----------
L.top(0, 0, 0, 16, 18, depth=3, theme="factory")                # x[-8,8] z[9,-9]
L.start(0, 0.1, 6, ry=PI)
L.ent("copy", 0, 0, -3, ability="miknatis")
L.ent("hint", 0, 0, -5, hint="ability", size=(8, 3, 5))
L.battery_line((0, 0, 4), (0, 0, 0), 3)
L.ent("crate", -5, 0, 5, batteries=3)
wall(-8, 8, -9, -12, 6.0, -3.0)                                  # sur (6 m)
L.ent("metal", 0, 5.4, -8.4, size=(2.4, 1.2, 1.2))               # surun üst kenarında metal tutamak
L.battery_line((0, 1.5, -6.5), (0, 6.5, -9.5), 3)
L.guide(0, 3, -7)
# Surun üstünden iç avluya (iniş)
L.top(0, 6.0, -10.5, 16, 3, depth=0.5, theme="stone")

# ---------- İç avlu: testereler ve dikenler ----------
L.top(0, 2.0, -21, 16, 18, depth=5, theme="factory")             # x[-8,8] z[-12,-30]
L.ent("checkpoint", -5.5, 2.0, -14, checkpoint_id="avlu", ry=PI)
L.ent("hazard", -5, 2.0, -18, kind="saw", move=(10, 0, 0), period=3.5)
L.ent("hazard", 4.5, 2.0, -21.5, kind="spikes", size=(6, 2))
L.ent("hazard", -4.5, 2.0, -24.5, kind="spikes", size=(6, 2))
L.battery_line((0, 2.0, -16), (0, 2.0, -26), 5)
# Kalıcı kapı: Kaya ile ağır buton
L.ent("copy", 5.5, 2.0, -26.5, ability="kaya")
L.ent("button", -5.5, 2.0, -27, targets=["../Kapi1"])
L.ent("gate", 0, 2.0, -30, name="Kapi1", size=(16, 4, 0.6), open_offset=(0, -4.2, 0))
L.guide(-5.5, 4, -27)

# ---------- Salon: Buz ile Hurda Goblin merdiveni (3,2 m çıkıntı) ----------
L.top(0, 2.0, -38, 16, 16, depth=5, theme="factory")             # z[-30,-46]
L.ent("copy", -5.5, 2.0, -33, ability="buz")
L.ent("hint", -3, 2.0, -40, hint="ability", size=(10, 3, 6))
for x in (-3.0, 2.5):
    L.ent("enemy", x, 2.0, -41, kind="hurdaci", speed=1.4, batteries=3)
L.top(0, 5.2, -49, 16, 6, depth=8, theme="stone")                # çıkıntı z[-46,-52] (3,2 m yukarı)
L.ent("checkpoint", -5.5, 5.2, -48, checkpoint_id="cikinti", ry=PI)
L.battery_arc((0, 2.0, -42), (0, 5.2, -47), 4, 2.0)
# Gizli Altın Vida: salonun yanındaki metal kule (Mıknatıs ile)
L.ent("copy", 6.0, 2.0, -33, ability="miknatis")
L.top(10.5, 9.0, -38, 3, 3, depth=12, theme="stone")             # kule x[9,12] (üstü 9)
L.ent("metal", 8.6, 7.6, -38, size=(0.8, 2.4, 2.4))              # kulenin yüzündeki metal levha
L.ent("screw", 10.5, 9.1, -38)
# Zamanlı kapı: çıkıntıdaki buton 6 sn açık tutar
L.ent("copy", 5.5, 5.2, -48, ability="kaya")
L.ent("button", 0, 5.2, -50, targets=["../Kapi2"], open_time=6.0)
L.ent("gate", 0, 5.2, -52, name="Kapi2", size=(16, 4, 0.6), open_offset=(0, -4.4, 0))

# ---------- Final parkuru: altı yetenek sırayla ----------
L.top(0, 5.2, -55, 6, 6, depth=8, theme="purple")                # P0 z[-52,-58]
L.ent("copy", 2.0, 5.2, -56.5, ability="yay")                     # 1) Yay
L.top(0, 9.5, -61.5, 6, 3, depth=3, theme="yellow")              # P1 z[-60,-63] (4,3 m yukarı)
L.ent("copy", 2.0, 9.5, -61.5, ability="balon")                   # 2) Balon
L.top(0, 7.0, -74, 6, 4, depth=3, theme="blue")                  # P2 z[-72,-76] (9 m süzülme)
L.battery_arc((0, 9.5, -63), (0, 7.0, -72), 5, 1.5)
L.ent("copy", 2.0, 7.0, -73, ability="pervane")                   # 3) Pervane
L.top(0, 13.0, -80, 6, 3, depth=3, theme="purple")               # P3 z[-78.5,-81.5] (6 m yukarı)
L.ent("copy", 2.0, 13.0, -80, ability="miknatis")                 # 4) Mıknatıs
L.ent("metal", 0, 12.5, -88, size=(2.4, 1.0, 2.4))                # yüzen metal blok (üstü 13)
L.top(0, 13.0, -93.75, 6, 2.5, depth=0.6, theme="factory")       # P4 ön z[-92.5,-95] (blok sonrası 3,3 m)
for sx in (-1, 1):
    L.top(sx * 2.25, 13.0, -96.5, 1.5, 3, depth=0.6, theme="factory")   # çatlağın yanları
L.top(0, 13.0, -98.25, 6, 0.5, depth=0.6, theme="factory")       # arka kenar
L.ent("copy", 2.2, 13.0, -93.5, ability="kaya")                   # 5) Kaya
L.ent("cracked", 0, 12.75, -96.5, size=(3, 0.5, 3))               # P4'ün ortasında çatlak
L.top(0, 9.0, -99, 6, 14, depth=1.0, theme="stone")              # alt oda z[-92,-106]
L.ent("copy", -2.0, 9.0, -103, ability="buz")                     # 6) Buz
L.top(0, 7.0, -111.5, 6, 11, depth=1.0, theme="stone")           # havuz tabanı z[-106,-117]
L.ent("water", 0, 9.0, -111.5, size=(6, 2, 11))
for sx in (-1, 1):
    L.box(sx * 3.5, 8.0, -111.5, 1, 4, 11, "stone")
L.top(0, 11.15, -120, 8, 6, depth=4.5, theme="factory")          # varış z[-117,-123] (suyun 2,15 m üstü)
L.ent("checkpoint", -3, 11.15, -118.5, checkpoint_id="final", ry=PI)
L.ent("exit", 0, 11.15, -121)
L.battery_line((0, 9.2, -108), (0, 9.2, -116), 4)

# Süs: kale kuleleri, fırtına
for x, z in ((-11, 6), (11, 6), (-11, -20), (-11, -45)):
    L.top(x, 10, z, 3, 3, depth=13, theme="stone")
    L.deco("flag", x, 10, z, 1.0)
L.ent("prop", -20, 30, -90, kind="storm", size=6.0)
L.clouds(16, xr=(-90, 90), zr=(-200, 40), avoid=(-25, 25, -130, 20), low=(-14, -8), high=(25, 40))
L.write()
