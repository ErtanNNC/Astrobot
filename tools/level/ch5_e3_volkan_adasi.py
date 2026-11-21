# Bölüm 5 (bonus) · Alan 3: Volkan Adası (yeni, 2026-11-21; Yay Bahçesi yöntemiyle).
# Tasarım: docs/features/bolum-5/design.md
# Yeni fikir: LAV. Lava değen yanar (son kontrol noktasına döner); Buz taşıyan Bip'in ayağının altında lav
# soğuyup taş karolara döner (water_zone lava=true). Yön işareti: sonda dumanı tüten dev volkan.
#   Kara Kumsal (Buz) → Lav Nehri (Buz ile üstünde yürü) → Bazalt Basamakları (düşen taşlar) → Gayzerler
#   (Balon ile yüksel) → Magma Zinciri (Mıknatıs) → Krater Kenarı (Pervane, bitiş).
# Gizli köşeler: nehirdeki adacık (Buz), ikinci gayzerin tepesindeki çıkıntı (Balon), krater kenarındaki niş.
# Çalıştırma: python3 tools/level/ch5_e3_volkan_adasi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch5_volkan", "Volkan Adası", "scenes/chapter5/e3_volkan_adasi.tscn", sky="sunset",
          music="res://assets/audio/opengameart/fasttheme.ogg", kill_height=-6, water=None, seed=53)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında. Bkz. lvl.py TURNS
L.turns([(0, -30, 30), (0, -58, -40), (0, -116, 30)])
LAVA_Y = 0.0


def lava(cz, length, width=12, y=LAVA_Y):
    """Lav havuzu: altta taban, üstte lav (değen yanar), yanlarda kaya duvar."""
    L.top(0, y - 1.8, cz, width, length, depth=1, theme="stone")
    L.ent("water", 0, y, cz, size=(width, 1.7, length), lava=True)
    for sx in (-1, 1):
        L.box(sx * (width / 2 + 0.5), y - 0.3, cz, 1, 3.4, length, "strata")


def ground(cx, top, cz, sx, sz, depth=6):
    L.top(cx, top, cz, sx, sz, depth=depth, theme="canyon", side="strata")


def rocks(x0, x1, z0, z1, y, n):
    L.scatter(["kaykit/forest/Rock_1_A_Color1.gltf", "kaykit/forest/Rock_2_A_Color1.gltf", "kaykit/forest/Tree_Bare_1_A_Color1.gltf"],
              x0, x1, z0, z1, y, n, 0.9, 1.4, clear=(-2.4, 2.4))


# =====================================================================================
# 0 · KARA KUMSAL (başlangıç)                                       x[-7,7] z[6,-6]
# =====================================================================================
ground(0, 0, 0, 14, 12)
L.start(0, 0.1, 3, ry=PI)
L.ent("copy", -3, 0, -2, ability="buz")
L.ent("hint", -3, 0, -2, hint="ability", size=(5, 3, 5))
L.battery_line((2, 0, 3), (2, 0, -4), 4)
L.ent("crate", 5.5, 0, 4, batteries=3)
rocks(-6.5, 6.5, -5.5, 5.5, 0, 6)
L.label(0, 5, -6.5, "Volkan Adası", 60)
L.guide(0, 2, -5)

# =====================================================================================
# 1 · LAV NEHRİ (Buz ile lavın üstünde yürü)                       lav z[-6,-24]
# =====================================================================================
lava(-15, 18)
L.battery_line((0, LAVA_Y + 0.3, -8), (0, LAVA_Y + 0.3, -22), 6)
L.guide(0, 2, -15)
# --- Gizli köşe 1: nehirdeki adacık (Buz ile) ---
L.top(4.0, 0.5, -15, 2.4, 2.4, depth=2.4, theme="canyon", side="strata")
L.ent("crate", 4.6, 0.5, -15.7, batteries=5)
L.battery_ring((3.8, 0.5, -14.8), 0.8, 5)
ground(0, 0, -30, 12, 12)                                         # B z[-24,-36]
L.ent("checkpoint", -4, 0, -27, checkpoint_id="nehir", ry=PI)
rocks(-5.5, 5.5, -35, -25, 0, 4)

# =====================================================================================
# 2 · BAZALT BASAMAKLARI (düşen taşlar, lavın üstünde)               lav z[-36,-53]
# =====================================================================================
lava(-44.5, 17, width=14)
for i, (x, z) in enumerate(((0.8, -39.5), (-0.8, -44.0), (0.8, -48.5))):
    L.ent("platform", x, -0.25, z, kind="fall", size=(3, 0.5, 3), color=(0.3, 0.28, 0.3, 1))
    L.battery(x, 0, z)
ground(0, 0, -58, 12, 10)                                         # C z[-53,-63]
L.ent("checkpoint", -4, 0, -55, checkpoint_id="bazalt", ry=PI)
L.ent("copy", 4, 0, -55, ability="balon")
L.ent("enemy", 0, 0, -60, kind="vidabocek", patrol=3, speed=1.2, batteries=2)

# =====================================================================================
# 3 · GAYZERLER (Balon ile sıcak hava akımında yüksel)              lav z[-63,-74]
# =====================================================================================
lava(-68.5, 11, width=14)
L.ent("wind", 0, -2, -68.5, size=(4, 13, 4), force=(0, 15, 0))
L.ent("prop", 0, LAVA_Y, -68.5, kind="rain", size=0.15, color=(1, 0.6, 0.2, 1))
L.battery_line((0, 2, -68.5), (0, 9, -68.5), 4)
ground(0, 8, -79, 12, 10, depth=14)                               # D z[-74,-84]
L.ent("checkpoint", -4, 8, -76, checkpoint_id="gayzer", ry=PI)
L.ent("copy", 4, 8, -76, ability="miknatis")
L.ent("hint", 0, 0, -62, hint="hold_jump", size=(8, 3, 2))
L.guide(0, 9, -68)
# --- Gizli köşe 2: ikinci gayzerin tepesinden doğudaki çıkıntıya ---
L.ent("wind", 5.0, -2, -68.5, size=(3, 15, 3), force=(0, 15, 0))
L.top(9.6, 12, -68.5, 3, 3, depth=0.8, theme="yellow")
L.ent("crate", 10.0, 12, -69.2, batteries=5)
L.battery_ring((9.6, 12, -68.5), 0.9, 5)

# =====================================================================================
# 4 · MAGMA ZİNCİRİ (Mıknatıs; lavın üstünde asılı metal bloklar)   lav z[-84,-112]
# =====================================================================================
lava(-98, 28, width=12, y=1.0)
for z in (-89.5, -97, -104.5):
    L.ent("metal", 0, 7, z, size=(2, 2, 2))
    L.battery(0, 8.6, z)
L.ent("metal", 0, 9, -112)                                        # iniş tutamağı
ground(0, 8, -116, 12, 8, depth=14)                               # E z[-112,-120]
L.ent("checkpoint", -4, 8, -114, checkpoint_id="zincir", ry=PI)
L.ent("copy", 4, 8, -114, ability="pervane")
L.guide(0, 10, -97)

# =====================================================================================
# 5 · KRATER KENARI (Pervane ile 6,5 m) — bitiş
# =====================================================================================
ground(0, 14.5, -126, 8, 6, depth=16)                              # F z[-123,-129]
L.battery_line((0, 9.5, -120.5), (0, 14.5, -123.5), 4)
L.ent("exit", 0, 14.5, -126.5)
L.battery_ring((0, 14.5, -126), 2.0, 6)
L.kit("signage_finish_wide", 0, 14.5, -123.4)
L.guide(0, 16.5, -122)
# --- Gizli köşe 3: krater kenarındaki niş (F'nin doğusu; Pervane) ---
L.top(7.0, 16, -126, 2.6, 2.6, depth=0.8, theme="red")
L.ent("crate", 7.6, 16, -126.8, batteries=5)
L.ent("screw", 6.8, 16.1, -125.6)
L.battery_ring((7.0, 16, -126), 0.9, 5)

# =====================================================================================
# Manzara: dev volkan (yön işareti), dumanlar, lav ışıltısı
# =====================================================================================
for i, (w, y0, y1) in enumerate(((60, -8, 6), (44, 6, 18), (30, 18, 28), (20, 28, 36))):
    L.box(0, (y0 + y1) / 2, -175, w, y1 - y0, w, "strata")
L.box(0, 36.2, -175, 12, 0.6, 12, "red")
for k in range(6):
    L.deco(random.choice(["cloud", "cloud2", "cloud3"]), random.uniform(-6, 6), 40 + k * 4, -175 + random.uniform(-4, 4), 1.2 + k * 0.2, parent="Clouds")
for (x, z) in ((-20, -40), (22, -80), (-24, -110), (20, -20)):
    L.box(x, -2, z, 10, 4, 10, "strata")
    L.ent("prop", x, 1, z, kind="lamp", size=1.6)

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("adacik", 4, 0.5, -15, 2.4, 2.4)
L.secret("gayzer", 9.6, 12, -68.5, 3, 3)
L.secret("nis", 7, 16, -126, 2.6, 2.6)
# Yeni düşman türleri (2026-11-21; docs/features/dusmanlar/design.md)
L.ent("enemy", 3, 0, -57, kind="dikenli", patrol=1.8, speed=1.1, batteries=2)
L.ent("enemy", -4, 8, -80, kind="atici", batteries=3)
L.write()
