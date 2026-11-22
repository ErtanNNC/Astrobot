# Bölüm 4 · Alan 2: Fırtına Köprüleri (yeni alan, 2026-11-21; Yay Bahçesi yöntemiyle).
# Tasarım: docs/features/bolum-4/design.md ("Fırtına Köprüleri" bölümü)
# Bulut Basamakları ile Kıvılcım Kalesi arasında, fırtınanın içinde gökte asılı taş köprüler ve kuleler.
# Yeni fikir: YAN RÜZGÂR. Köprülerde ritimle esen yan rüzgâr Bip'i boşluğa iter; Kaya rüzgârdan etkilenmez.
#   Giriş Bulutu → Rüzgârlı Köprü (öğret: Kaya ile dayan ya da rüzgârın dinmesini bekle) → Pervane Kulesi
#   → Mıknatıs Zinciri (fırtına boşluğu) → Yan rüzgârda Balon süzülüşü (şaşırt) → Yay ile Fırtına Kulesi (bitiş).
# Gizli köşeler: köprünün altındaki çıkıntı (rüzgâr seni oraya atabilir; trambolinle dön), Pervane kulesinin
# yanındaki paratoner tablası (Altın Vida), bitiş kulesinin yanındaki Fırtına Gözü sütunu (Yay).
# Çalıştırma: python3 tools/level/ch4_d1b_firtina_kopruleri.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch4_kopru", "Fırtına Köprüleri", "scenes/chapter4/d1b_firtina_kopruleri.tscn", sky="storm",
          kill_height=-12, water=None, seed=43)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -33, 45), (0, -46, -60), (0, -82, 40)])
MD = "kaykit/medieval/"


def pylon(cx, top, cz, sx, sz, theme="castle"):
    """Gökte asılı taş kule: üst zemin + altta daralan gövde + sarkan zincirler (süs)."""
    L.top(cx, top, cz, sx, sz, depth=3, theme=theme)
    L.box(cx, top - 6, cz, sx * 0.7, 6, sz * 0.7, "castle")
    L.box(cx, top - 10, cz, sx * 0.4, 2.5, sz * 0.4, "castle")
    for ex in (-1, 1):
        L.model("kenney/holiday/lantern.glb", cx + ex * (sx / 2 - 0.5), top, cz + sz / 2 - 0.5, 0, 1.6)


def rod(x, y, z, h=6):
    """Paratoner: ince metal direk, tepesinde parlayan küre (süs, çarpışmasız gibi ince)."""
    L.box(x, y + h / 2, z, 0.25, h, 0.25, "factory")
    L.ent("prop", x, y + h + 0.3, z, kind="lamp", size=0.9)


# =====================================================================================
# 0 · GİRİŞ BULUTU                                                   x[-7,7] z[6,-6]
# =====================================================================================
L.top(0, 0, 0, 14, 12, depth=3, theme="cloud")
L.start(0, 0.1, 3, ry=PI)
L.ent("copy", 3, 0, -2.5, ability="kaya")
L.ent("hint", 3, 0, -2.5, hint="ability", size=(5, 3, 5))
L.battery_line((-3, 0, 4), (-3, 0, -3), 4)
L.ent("crate", -5, 0, -4, batteries=3)
L.label(0, 5, -6.5, "Fırtına Köprüleri", 60)
L.guide(0, 2, -5)

for (x, z) in ((-5.6, 5.2), (5.6, 5.2), (-5.6, -5.2), (5.6, -5.2)):
    L.model("kenney/holiday/lantern.glb", x, 0, z, 0, 1.8)
L.model("kaykit/medieval/flag_red.gltf", -6.2, 0, -0.5, 0, 4.0); L.model("kaykit/medieval/flag_red.gltf", 6.2, 0, -0.5, 0, 4.0)
L.model("kaykit/medieval/barrel.gltf", 4.6, 0, 2.6, 0.3, 5.0); L.model("kaykit/medieval/crate_A_big.gltf", 5.4, 0, 1.4, 0.8, 5.0)

# =====================================================================================
# 1 · ÖĞRET: RÜZGÂRLI KÖPRÜ (yan rüzgâr ritimle eser; Kaya ile dayan)
# =====================================================================================
L.top(0, 0, -17, 3.5, 22, depth=1, theme="castle")                # z[-6,-28]
L.ent("wind", 0, -1, -12, size=(12, 5, 6), force=(16, 0, 0), cycle=3.0, offset=0.0)
L.ent("wind", 0, -1, -22, size=(12, 5, 6), force=(-16, 0, 0), cycle=3.0, offset=1.5)
L.ent("hint", 0, 0, -8, hint="ability", size=(4, 3, 3), delay=4.0)
L.battery_line((0, 0, -8), (0, 0, -26), 7)
for z in (-6.5, -27.5):
    for x in (-1.6, 1.6):
        L.box(x, 0.6, z, 0.3, 1.2, 0.3, "red")                     # köprü babaları
# --- Gizli köşe 1: köprünün altındaki çıkıntı (rüzgâr atabilir), trambolinle geri ---
L.top(5.5, -4, -17, 3.5, 6, depth=1, theme="castle")
L.ent("crate", 6.2, -4, -19, batteries=5)
L.battery_ring((5.5, -4, -16.5), 1.0, 6)
L.ent("trampoline", 4.6, -4, -15.0, height=6.0)

# =====================================================================================
# 2 · PERVANE KULESİ (6,5 m)
# =====================================================================================
pylon(0, 0, -33, 10, 10)                                           # P1 z[-28,-38]
L.ent("checkpoint", -3, 0, -31, checkpoint_id="kopru1", ry=PI)
L.ent("copy", 3, 0, -35, ability="pervane")
L.ent("enemy", 1.5, 0, -37, kind="vidabocek", patrol=1.5, speed=1.2, batteries=2)   # kontrol noktasından uzağa (2. oynanış kaydı: doğar doğmaz hasar)
L.battery_line((0, 1.5, -38.5), (0, 7.0, -41.5), 4)
pylon(0, 6.5, -46, 10, 8)                                          # P2 z[-42,-50]
L.ent("copy", 3, 6.5, -44, ability="miknatis")
L.guide(0, 8.5, -42)
# --- Gizli köşe 2: paratoner tablası (Pervane, P2'nin doğusu) → Altın Vida ---
L.top(9, 10.5, -46, 2.5, 2.5, depth=0.5, theme="yellow")
L.ent("screw", 9, 10.6, -46)
rod(9.9, 10.5, -46.9, 4)
L.battery_arc((4.5, 7, -46), (8.5, 10.5, -46), 3, 1.5)

# =====================================================================================
# 3 · MIKNATIS ZİNCİRİ (fırtına boşluğunun üstünde, 5,5 m aralık)
# =====================================================================================
for z in (-55.5, -63, -70.5):
    L.ent("metal", 0, 5.5, z, size=(2, 2, 2))
    L.battery(0, 7.1, z)
    L.box(0, 2.5, z, 0.3, 4, 0.3, "factory")                       # bloğu tutan zincir (süs)
L.ent("metal", 0, 7.5, -78)                                        # iniş tutamağı
pylon(0, 6.5, -82, 12, 10)                                         # P3 z[-77,-87]
L.ent("checkpoint", 4, 6.5, -84, checkpoint_id="zincir", ry=PI)
L.ent("copy", -4, 6.5, -80, ability="balon")
L.ent("enemy", -2, 6.5, -85, kind="zipzip", batteries=2)   # kontrol noktasından uzağa (2. oynanış kaydı: doğar doğmaz hasar)
L.battery_ring((0, 6.5, -82.5), 2.2, 6)
L.guide(0, 9, -63)

# =====================================================================================
# 4 · ŞAŞIRT: YAN RÜZGÂRDA BALON SÜZÜLÜŞÜ (rüzgâr doğuya sürükler; iniş kulesi doğuda geniş)
# =====================================================================================
L.ent("wind", 0, -2, -93, size=(14, 12, 10), force=(3, 0, 0))
L.battery_arc((0, 7, -87.5), (4, 4, -98.5), 6, 2.0)
pylon(4, 4.0, -103, 14, 8)                                         # P4 x[-3,11] z[-99,-107]
L.ent("checkpoint", -1, 4.0, -101, checkpoint_id="ruzgar2", ry=PI)
L.ent("copy", 1, 4.0, -101, ability="yay")
L.ent("enemy", 7, 4.0, -104, kind="vidabocek", patrol=2.5, speed=1.3, batteries=2)
L.ent("crate", 9.5, 4.0, -106, batteries=3)
L.guide(2, 7, -93)

# =====================================================================================
# 5 · USTALIK: YAY İLE FIRTINA KULESİ (4,5 m basamaklar) ve bitiş
# =====================================================================================
L.top(1, 8.5, -110.5, 4, 4, depth=1, theme="red")                  # S1 z[-108.5,-112.5]
L.top(1, 13.0, -115.5, 4, 4, depth=1, theme="yellow")              # S2 z[-113.5,-117.5]
L.battery_arc((1, 4.5, -107), (1, 8.5, -110), 3, 2.5)
L.battery_arc((1, 8.5, -112), (1, 13, -115), 3, 2.5)
pylon(0, 17.5, -123.5, 12, 10)                                     # F z[-118.5,-128.5]
L.ent("checkpoint", -4, 17.5, -121, checkpoint_id="kule", ry=PI)
L.battery_ring((0, 17.5, -124), 2.5, 8)
L.ent("exit", 0, 17.5, -126)
L.kit("signage_finish_wide", 0, 17.5, -119.5)
L.model(MD + "flag_red.gltf", -5, 17.5, -128, 0, 5.0); L.model(MD + "flag_red.gltf", 5, 17.5, -128, 0, 5.0)
L.guide(1, 15, -113)
# --- Gizli köşe 3: Fırtına Gözü sütunu (F'nin doğusu, Yay ile) ---
L.top(9.5, 22, -123.5, 2.6, 2.6, depth=0.5, theme="purple")
L.ent("crate", 9.5, 22, -124, batteries=5)
L.battery_ring((9.5, 22, -123.5), 0.9, 5)
rod(10.4, 22, -124.4, 3)

# =====================================================================================
# Manzara: yağmur, fırtına bulutları, paratonerler, uzakta Kıvılcım Kalesi (yön işareti)
# =====================================================================================
for z in (-10, -60, -110):
    L.ent("prop", 0, 20, z, kind="rain", size=1.6, parent="Decor")
for (x, y, z) in ((-14, 10, -30), (16, 14, -70), (-18, 18, -110), (20, 22, -140)):
    L.ent("prop", x, y, z, kind="storm", size=3.0, parent="Decor")
for (x, y, z) in ((-4.5, 0, -30), (4.5, 6.5, -85), (-6, 17.5, -127)):
    rod(x, y, z)
L.top(10, 8, -190, 30, 24, depth=4, theme="cloud")
L.model(MD + "building_castle_red.gltf", 10, 8, -190, 0.2, 9.0)
for (x, z) in ((-3, -180), (23, -180), (-3, -200), (23, -200)):
    L.model(MD + "building_tower_B_red.gltf", x, 8, z, 0, 6.0)
for i in range(16):
    L.deco(random.choice(["cloud", "cloud2", "cloud3"]), random.choice([-1, 1]) * random.uniform(14, 34),
           random.uniform(-16, -8), random.uniform(-150, 10), random.uniform(0.8, 1.6), parent="Clouds")
L.clouds(12, xr=(-90, 90), zr=(-220, 40), avoid=(-25, 25, -140, 20), low=(-14, -8), high=(26, 40))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("cikinti", 5.5, -4, -17, 3.5, 6)
L.secret("firtina_gozu", 9.5, 22, -123.5, 2.6, 2.6)
# Yeni düşman türleri (2026-11-21; docs/features/dusmanlar/design.md)
L.ent("enemy", 9, 4.0, -101.5, kind="atici", batteries=3)
L.ent("enemy", -2.5, 6.5, -45, kind="dikenli", patrol=1.5, speed=1.1, batteries=2)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.setpiece("lightning", 0, 6.5, -48, (-17, 4, -62), size=(10, 5, 3), big=0.8)
L.write()
