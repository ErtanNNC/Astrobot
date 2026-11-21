# Bölüm 5 (bonus) · Alan 1: Oyuncak Kasabası (yeni, 2026-11-21; Yay Bahçesi yöntemiyle).
# Tasarım: docs/features/bolum-5/design.md
# Dev bir oyun masasının üstünde, havada duran oyuncaklar: hediye kutuları, raflar, oyuncak tren, kale, dev
# Fındıkkıran (yön işareti, başlangıçtan görünür). Bütün yetenekler sırayla:
#   Oyun Halısı (Yay) → Hediye Kulesi (Yay ile 4 m'lik kutular) → Oyuncak Rafı → Tren (hareketli vagon)
#   → Balon ile kaleye süzülüş → Mıknatıs levhalarıyla kale kulesi → Pervane ile Fındıkkıran'ın şapkası (bitiş).
# Gizli köşeler: başlangıcın arkasındaki top havuzu (trambolinle dön), şeker kamışı sütunu (Altın Vida, Yay),
# trenin altındaki gizli raf (tren geçerken in).
# Çalıştırma: python3 tools/level/ch5_e1_oyuncak_kasabasi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch5_oyuncak", "Oyuncak Kasabası", "scenes/chapter5/e1_oyuncak_kasabasi.tscn", sky="day",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-6, water=None, seed=51)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -51, 45), (0, -80, -40)])
KH = "kaykit/holiday/"
H = "kenney/holiday/"
PRESENT_H = 4.0                       # hediye kutusu basamağı (Yay ile çıkılır)


def present(x, base, z, model="present_D_yellow"):
    """Dev hediye kutusu: görüntü KayKit Holiday modeli, çarpışma kutusu (üstü base + 4 m)."""
    s = PRESENT_H / 1.06
    L.model(KH + model + ".gltf", x, base, z, 0, s)
    w = 0.96 * s
    L.solid(x, base + PRESENT_H / 2, z, w, PRESENT_H, w)
    return w


# =====================================================================================
# 0 · OYUN HALISI (başlangıç)                                      x[-8,8] z[7,-7]
# =====================================================================================
L.top(0, 0, 0, 16, 14, depth=2, theme="blue")
L.start(0, 0.1, 4, ry=PI)
L.ent("copy", -3, 0, -3, ability="yay")
L.ent("hint", -3, 0, -3, hint="ability", size=(5, 3, 5))
L.battery_line((2, 0, 4), (2, 0, -4), 4)
L.ent("crate", 6, 0, 4, batteries=3)
L.model(KH + "present_E_red.gltf", -6.5, 0, 5, 0.4, 2.0); L.model(KH + "present_B_green.gltf", 6.6, 0, -5.5, 1.0, 2.2)
L.model(H + "gingerbread-man.glb", -6.6, 0, -5.6, 0.6, 3.0); L.model(KH + "football.gltf", 5.0, 0.6, 1.0, 0, 2.0)
L.label(0, 5.5, -7.5, "Oyuncak Kasabası", 64)
L.guide(0, 2, -6)
# Arka kenardan inen pil sırası: top havuzunu ima eder
L.battery_line((0, 0.4, 6.4), (0, -2.0, 9.0), 3)

# --- Gizli köşe 1: top havuzu (başlangıcın arkasında aşağıda), trambolinle dön ---
L.top(0, -3.5, 12, 8, 6, depth=1.5, theme="yellow")                 # z[9,15]
for _ in range(14):
    L.model(KH + random.choice(("football", "basketball", "present_sphere_A_blue")), random.uniform(-3.4, 3.4), -3.2,
            random.uniform(10.0, 14.6), random.uniform(0, 6.28), random.uniform(1.4, 2.0))
L.ent("crate", -2.6, -3.5, 13.8, batteries=5)
L.battery_ring((1, -3.5, 12.4), 1.4, 7)
L.ent("trampoline", 2.4, -3.5, 10.4, height=6.5)

# =====================================================================================
# 1 · HEDİYE KULESİ (Yay ile 4 m'lik kutular)
# =====================================================================================
present(0, 0, -9.0, "present_D_yellow")                             # üst 4, z[-7.2,-10.8]
present(0, 4, -12.6, "present_E_red")                               # üst 8, z[-10.8,-14.4]
present(0, 8, -16.2, "present_B_green")                             # üst 12, z[-14.4,-18]
L.battery_line((0, 0.6, -6.6), (0, 3.6, -6.9), 3)
L.battery_line((0, 4.6, -10.4), (0, 7.6, -10.6), 3)
L.battery_line((0, 8.6, -14.0), (0, 11.6, -14.2), 3)
L.guide(0, 9, -12)
# --- Gizli köşe 2: şeker kamışı sütunu (Altın Vida), Yay ile yeşil kutudan doğuya ---
L.top(5.2, 15.5, -16.2, 2.4, 2.4, depth=0.6, theme="red")
L.model(H + "candy-cane-red.glb", 5.2, 3.5, -16.2, PI / 2, 26.0)
L.solid(5.2, 9.5, -16.2, 0.6, 12, 0.6)
L.ent("screw", 5.2, 15.6, -16.2)

# =====================================================================================
# 2 · OYUNCAK RAFI ve TREN
# =====================================================================================
L.top(0, 12, -24, 12, 12, depth=1.2, theme="wood")                   # Raf 1 z[-18,-30]
L.ent("checkpoint", -4, 12, -21, checkpoint_id="raf", ry=PI)
L.ent("copy", 4, 12, -21, ability="balon")                          # ileride lazım (süzülüş)
L.ent("enemy", 2, 12, -26, kind="zipzip", batteries=2)
L.ent("crate", -4.5, 12, -28.5, batteries=3)
for x in (-5.4, 5.4):
    L.box(x, 7, -24, 0.4, 10, 0.4, "wood")                           # raf ayakları (süs, aşağı iner)
# Tren: vagon gibi görünen hareketli platform, rafın ucundan diğer rafa taşır
tr = L.ent("platform", 0, 11.75, -33.5, kind="move", size=(3.2, 0.5, 6), offset=(0, 0, -10), duration=3.0, color=(0.85, 0.3, 0.3, 1))
L.ent("prop", 0, -3.6, 0, parent="Entities/" + tr, kind="model", size=6.5, model_path="res://assets/models/kaykit/holiday/train_wagon.gltf")
L.ent("prop", 0, -4.1, -5.4, parent="Entities/" + tr, kind="model", size=6.5, model_path="res://assets/models/kaykit/holiday/train_locomotive.gltf")
for x in (-1.1, 1.1):
    L.box(x, 7.95, -38.5, 0.25, 0.2, 16, "factory")                  # raylar (süs)
L.battery_line((0, 12.8, -31), (0, 12.8, -45), 5)
L.top(0, 12, -51, 12, 10, depth=1.2, theme="wood")                   # Raf 2 z[-46,-56]
L.ent("enemy", -3, 12, -52, kind="vidabocek", patrol=2.5, speed=1.3, batteries=2)
L.battery_ring((0, 12, -51), 2.0, 6)
L.guide(0, 14, -40)
# --- Gizli köşe 3: trenin altındaki gizli raf (raf 1'in ucundan aşağı in) ---
L.top(-5.5, 8, -38, 4, 5, depth=0.8, theme="wood")
L.ent("crate", -5.5, 8, -39.5, batteries=5)
L.battery_ring((-5.5, 8, -37.5), 1.0, 5)
L.ent("trampoline", -4.6, 8, -36.4, height=5.5)

# =====================================================================================
# 3 · BALON: kaleye süzülüş (12 m, 3 m aşağı)
# =====================================================================================
L.battery_arc((0, 12.5, -56.5), (0, 9.2, -66), 6, 2.0)
L.top(0, 9, -70, 12, 10, depth=2, theme="red")                       # Kale avlusu z[-65,-75]
L.ent("checkpoint", 4, 9, -67, checkpoint_id="kale", ry=PI)
L.ent("copy", -4, 9, -67, ability="miknatis")
L.ent("enemy", 2, 9, -71, kind="hurdaci", speed=1.3, batteries=3)
for x in (-6.2, 6.2):
    L.model("kaykit/medieval/building_tower_B_red.gltf", x, 9, -74, 0, 2.6)
L.guide(0, 12, -60)

# =====================================================================================
# 4 · MIKNATIS: kale kulesinin metal levhaları (7 m)
# =====================================================================================
L.top(0, 16, -80, 12, 10, depth=18, theme="purple")                  # Kule z[-75,-85]
L.ent("metal", 0, 10.8, -74.5, size=(2, 1.6, 1))
L.ent("metal", 0, 13.8, -74.5, size=(2, 1.6, 1))
L.ent("metal", 0, 16.05, -74.5, size=(2, 1.1, 1))
L.battery_line((1.6, 11, -73.6), (1.6, 15.5, -73.6), 3)
L.ent("copy", 4, 16, -78, ability="pervane")
L.ent("checkpoint", -4, 16, -78, checkpoint_id="kule", ry=PI)
L.guide(0, 13, -73)

# =====================================================================================
# 5 · PERVANE: Fındıkkıran'ın şapkası (6,5 m) — bitiş
# =====================================================================================
L.top(0, 22.5, -91, 8, 6, depth=1.5, theme="yellow")                 # Şapka z[-88,-94]
L.battery_line((0, 17.5, -85.5), (0, 22.5, -88.5), 4)
L.ent("exit", 0, 22.5, -91.5)
L.battery_ring((0, 22.5, -91), 2.2, 6)
L.kit("star_yellow", 0, 27, -91, s=2.2)
L.guide(0, 24.5, -88)
# Dev Fındıkkıran (yön işareti): masanın üstünde durur, şapkası bitiş platformunun hemen arkasında
L.model(H + "nutcracker.glb", 0, -8, -100, 0, 22.0)

# =====================================================================================
# Manzara: dev oyun masası (aşağıda), oyuncak trenler, hediyeler, bulutlar
# =====================================================================================
L.box(0, -9, -45, 90, 2, 170, "wood")
for (x, z, m, s) in ((-22, -10, "present_D_yellow", 9), (24, -30, "present_E_red", 10), (-26, -60, "present_B_green", 11),
                     (22, -80, "gingerbread_house_decorated", 9), (-20, -100, "present_A_red", 12), (26, 10, "bell_decorated", 8)):
    L.model(KH + m + ".gltf", x, -8, z, random.uniform(0, 6.28), s)
L.model(H + "train-locomotive.glb", -14, -8, -40, PI / 2, 14.0); L.model(H + "train-wagon.glb", -14, -8, -31, PI / 2, 14.0)
L.clouds(16, xr=(-100, 100), zr=(-200, 60), avoid=(-30, 30, -120, 20), low=(-4, 0), high=(30, 45))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("top_havuzu", 0, -3.5, 12, 8, 6)
L.secret("gizli_raf", -5.5, 8, -38, 4, 5)
# Yeni düşman türleri (2026-11-21; docs/features/dusmanlar/design.md)
L.ent("enemy", -2, 12, -23, kind="dikenli", patrol=2.0, speed=1.1, batteries=2)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.setpiece("fireworks", 0, 22.5, -90, (0, 29, -100), size=(8, 4, 4))
L.write()
