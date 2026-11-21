# Bölüm 5 (bonus) · Alan 2: Yıldız Gözlemevi (yeni, 2026-11-21; Yay Bahçesi yöntemiyle).
# Tasarım: docs/features/bolum-5/design.md
# Gece, gökte süzülen ay kayaları ve yıldızlar; sonda dev teleskoplu gözlemevi (yön işareti).
#   Ay Kayası (Buz) → Yıldız Gölü (Buz ile suyun üstünde yürü) → Meteor Çukuru (Kaya ile camı kır, tünelden geç,
#   trambolinle çık) → Takımyıldız (dönen yıldızlar, Yay) → Teleskop Rüzgârı (Balon ile yüksel) → Gözlemevi kubbesi.
# Gizli köşeler: göldeki adacık (Buz ile), tünelin yan oyuğu (Altın Vida), kayan yıldız tablası (trambolin).
# Çalıştırma: python3 tools/level/ch5_e2_yildiz_gozlemevi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch5_gozlemevi", "Yıldız Gözlemevi", "scenes/chapter5/e2_yildiz_gozlemevi.tscn", sky="night",
          music="res://assets/audio/opengameart/snow_theme_loop.ogg", kill_height=-10, water=None, seed=52)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -58, 40), (0, -92, -50)])


def lamp(x, y, z, s=1.0):
    L.ent("prop", x, y, z, kind="lamp", size=s)


# =====================================================================================
# 0 · AY KAYASI (başlangıç)                                         x[-7,7] z[6,-6]
# =====================================================================================
L.top(0, 0, 0, 14, 12, depth=4, theme="castle")
L.start(0, 0.1, 3, ry=PI)
L.ent("copy", -3, 0, -2, ability="buz")
L.ent("hint", -3, 0, -2, hint="ability", size=(5, 3, 5))
L.battery_line((2, 0, 3), (2, 0, -4), 4)
L.ent("crate", 5.5, 0, 4, batteries=3)
lamp(-6, 2.6, -5.5); lamp(6, 2.6, -5.5)
L.label(0, 5, -6.5, "Yıldız Gözlemevi", 60)
L.guide(0, 2, -5)

# =====================================================================================
# 1 · YILDIZ GÖLÜ (Buz ile suyun üstünde yürü; uzak kıyı yüzerek çıkılamayacak kadar yüksek)
# =====================================================================================
L.top(0, -3, -14, 12, 16, depth=1, theme="stone")                  # göl tabanı z[-6,-22]
L.ent("water", 0, 0, -14, size=(12, 3, 16))
for sx in (-1, 1):
    L.box(sx * 6.5, -1.2, -14, 1, 3.6, 16, "ice")
L.battery_line((0, 0.3, -8), (0, 0.3, -20), 6)
L.guide(0, 2, -14)
# --- Gizli köşe 1: göldeki adacık (Buz ile yürüyerek) ---
L.top(4.0, 0.8, -15, 2.4, 2.4, depth=3.8, theme="ice")
L.ent("crate", 4.6, 0.8, -15.7, batteries=5)
L.battery_ring((4.0, 0.8, -15), 0.9, 5)
L.top(0, 2.15, -27, 12, 10, depth=5, theme="ice")                   # kıyı A z[-22,-32]
L.ent("checkpoint", -4, 2.15, -24, checkpoint_id="gol", ry=PI)

# =====================================================================================
# 2 · METEOR ÇUKURU (Kaya ile cam zemini kır, tünelden geç, trambolinle çık)
# =====================================================================================
L.ent("copy", 4, 2.15, -25, ability="kaya")
L.top(-4, 2.15, -34, 4, 4, depth=5, theme="ice")                    # deliğin yanları
L.top(4, 2.15, -34, 4, 4, depth=5, theme="ice")
L.ent("cracked", 0, 1.85, -34, size=(4, 0.6, 4))                    # cam zemin
L.ent("hint", 0, 2.15, -33, hint="ability", size=(5, 3, 4), delay=5.0)
L.box(0, 7.3, -36.5, 12, 11.4, 1, "ice")                            # aşılamaz buz duvarı y[1,6..13]
L.box(0, 1.875, -43, 12, 0.55, 12, "ice")                           # tünel tavanı (kubbe camı) z[-37,-49]
L.top(0, -4, -43, 4, 20, depth=1, theme="stone")                    # tünel tabanı z[-33,-53]
L.box(-2.5, -1.2, -43, 1, 5.6, 20, "castle")                         # batı duvarı z[-33,-53]
L.box(2.5, -1.2, -37.7, 1, 5.6, 9.4, "castle")                       # doğu duvarı z[-33,-42.4]
L.box(2.5, -1.2, -49.3, 1, 5.6, 7.4, "castle")                       # doğu duvarı z[-45.6,-53] (arada oyuk)
L.battery_line((0, -4, -37), (0, -4, -48), 5)
lamp(0, -1.0, -42, 0.8)
L.ent("trampoline", 0, -4, -51, height=9.0)                         # tünelin sonu: açık gök
L.guide(0, 3.5, -34)
# --- Gizli köşe 2: tünelin doğu duvarındaki oyuk (Altın Vida) ---
L.top(3.8, -4, -44, 2.6, 2.6, depth=1, theme="stone")
L.box(5.4, -1.2, -44, 0.6, 5.6, 3, "castle"); L.box(3.8, -1.2, -42.4, 3, 5.6, 0.4, "castle"); L.box(3.8, -1.2, -45.6, 3, 5.6, 0.4, "castle")
L.ent("screw", 4.2, -3.9, -44)
L.top(0, 2.15, -58, 12, 12, depth=5, theme="castle")                # kıyı C z[-52,-64]
L.ent("checkpoint", -4, 2.15, -55, checkpoint_id="meteor", ry=PI)
L.ent("copy", 4, 2.15, -55, ability="yay")
L.ent("enemy", 0, 2.15, -60, kind="vidabocek", patrol=3, speed=1.2, batteries=2)
lamp(-5.6, 4.6, -62); lamp(5.6, 4.6, -62)
# --- Gizli köşe 3: kayan yıldız tablası (C'nin doğusundaki trambolinden) ---
L.ent("trampoline", 5.0, 2.15, -59.5, height=7.0)
L.top(9.5, 9.0, -59.5, 3, 3, depth=0.6, theme="yellow")
L.ent("crate", 9.9, 9.0, -60.2, batteries=5)
L.battery_ring((9.5, 9.0, -59.5), 1.0, 5)
L.kit("star_yellow", 9.5, 12.5, -59.5, s=1.6)

# =====================================================================================
# 3 · TAKIMYILDIZ: dönen yıldız platformları, Yay ile 4 m basamaklar
# =====================================================================================
L.ent("platform", -1, 1.9, -69, kind="spin", size=(7, 0.5, 7), duration=10.0, color=(0.98, 0.84, 0.32, 1))
L.ent("platform", 3, 5.9, -76, kind="spin", size=(6, 0.5, 6), duration=-8.0, color=(0.6, 0.75, 1.0, 1))
L.ent("platform", -2, 9.9, -83, kind="spin", size=(6, 0.5, 6), duration=7.0, color=(0.98, 0.84, 0.32, 1))
L.battery_line((-1, 2.4, -66), (-1, 2.4, -72), 3)
L.battery_arc((0, 2.4, -72), (3, 6.4, -75), 3, 2.0)
L.battery_arc((3, 6.4, -77), (-2, 10.4, -82), 3, 2.0)
L.top(0, 10.15, -92, 10, 8, depth=3, theme="castle")                # D z[-88,-96]
L.ent("checkpoint", -3, 10.15, -90, checkpoint_id="takimyildiz", ry=PI)
L.ent("copy", 3, 10.15, -90, ability="balon")
L.guide(0, 8, -76)

# =====================================================================================
# 4 · TELESKOP RÜZGÂRI (Balon ile yüksel) ve GÖZLEMEVİ (bitiş)
# =====================================================================================
L.ent("wind", 0, -8, -100.5, size=(5, 30, 5), force=(0, 16, 0))
L.battery_line((0, 12, -100.5), (0, 21, -100.5), 4)
L.ent("hint", 0, 10.15, -95, hint="hold_jump", size=(8, 3, 2))
L.top(0, 20, -109, 10, 8, depth=3, theme="purple")                  # Kubbe terası z[-105,-113]
L.ent("exit", 0, 20, -110.5)
L.battery_ring((0, 20, -109), 2.4, 8)
L.kit("signage_finish_wide", 0, 20, -105.6)
L.guide(0, 23, -102)
# Gözlemevi: kule gövdesi + kubbe + dev teleskop (süs; yön işareti)
L.box(0, 8, -117, 8, 24, 8, "castle")
L.ent("prop", 0, 20.5, -117, kind="generator", size=1.6, color=(0.5, 0.8, 1.0, 1))
L.box(0, 27, -116, 1.6, 1.6, 12, "factory", rx=0.6)
L.kit("star_yellow", 0, 34, -117, s=3.0)

# =====================================================================================
# Manzara: yıldızlar ve ay kayaları
# =====================================================================================
for _ in range(40):
    x = random.choice((-1, 1)) * random.uniform(12, 60)
    L.kit("star_" + random.choice(("yellow", "blue")), x, random.uniform(-6, 40), random.uniform(-150, 30), ry=random.uniform(0, 6.28), s=random.uniform(0.8, 2.0))
for (x, y, z, w) in ((-22, -6, -20, 10), (24, -4, -50, 12), (-26, 2, -90, 12), (22, 6, -120, 10)):
    L.top(x, y, z, w, w, depth=6, theme="castle")
    L.ent("prop", x, y + 2.6, z, kind="lamp", size=1.4)

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("adacik", 4, 0.8, -15, 2.4, 2.4)
L.secret("yildiz", 9.5, 9, -59.5, 3, 3)
# Yeni düşman türleri (2026-11-21; docs/features/dusmanlar/design.md)
L.ent("enemy", 4, 2.15, -61.5, kind="atici", batteries=3)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.vista(0, 0, 0.5, (0, 27, -117), "Gözlemevi", size=(14, 4, 2))
L.setpiece("meteor", 0, 10.15, -94, (22, 6.3, -120), size=(10, 5, 3))
L.write()
