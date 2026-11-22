# Bölüm 1 · Alan 4: Kaya Ocağı. Tasarım: docs/features/bolum-1/design.md
# Öğret: Kaya ile ağır buton, çatlak zemin · Sına: zaman sınırlı kapılar, ezilecek düşmanlar
# Şaşırt: Kaya ile dibe batıp suyun altındaki yolu bulmak · Ustalık: dört yeteneği sırayla isteyen parkur
# Her zorunlu yeteneğin kaynağı gerektiği yerin hemen yanında (soft-lock yok).
# Çalıştırma: python3 tools/level/ch1_a4_kaya_ocagi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_kaya", "Kaya Ocağı", "scenes/chapter1/a4_kaya_ocagi.tscn", sky="quarry",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-14, water=-9, seed=44)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -113, 35), (0, -126, -45)])
PI = math.pi
Q = "quarry"


def wall(x0, x1, z0, z1, top, bottom=0.0, theme="qstrata"):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


F = "kaykit/forest/"
SB = "kaykit/spacebase/"
ROCKS = ("Rock_1_A_Color1", "Rock_1_E_Color1", "Rock_1_J_Color1", "Rock_3_A_Color1", "Rock_3_E_Color1", "Rock_3_K_Color1", "Rock_3_Q_Color1")


def fm(model, x, y, z, ry=0.0, s=1.0):
    """KayKit Forest (kaya, çıplak ağaç, çalı) süsü, çarpışmasız."""
    L.model(F + model, x, y, z, ry, s)


def sb(model, x, y, z, ry=0.0, s=1.0):
    """KayKit Space Base (maden kulesi, kamyon, kasalar, ışıklar) süsü, çarpışmasız."""
    L.model(SB + model, x, y, z, ry, s)


def rubble(x0, x1, z0, z1, y, n):
    """Zemine yayılmış küçük taşlar ve çalılar (çarpışmasız)."""
    for _ in range(n):
        m = random.choice(("Rock_1_A_Color1", "Rock_1_E_Color1", "Rock_1_J_Color1", "Rock_2_A_Color1", "Rock_2_D_Color1", "Bush_1_A_Color1", "Grass_2_A_Color1"))
        x = random.uniform(x0, x1)
        if abs(x) < 2.2:            # yürüme hattını boş bırak
            x += 2.2 if x >= 0 else -2.2
        fm(m, x, y, random.uniform(z0, z1), random.uniform(0, 6.28), random.uniform(0.7, 1.1))


def rocks(x0, x1, z0, z1, y, n):
    for _ in range(n):
        L.rock(random.uniform(x0, x1), y, random.uniform(z0, z1), random.uniform(0.5, 0.9))


# Ocak duvarları (arka plan)
for side, z0, z1 in L.wall_spans(12, -175, dist=13):
    h = 14 if z0 > -60 else (18 if z0 > -120 else 16)
    L.box(side * 18, h / 2 - 8, (z0 + z1) / 2, 10, h + 16, abs(z1 - z0), "qstrata")
    L.top(side * 21, h + 2, (z0 + z1) / 2, 6, abs(z1 - z0), depth=4, theme="grass", side="qstrata")   # basamaklı üst kat
    for z in range(int(z0) - 6, int(z1), -9):
        fm(random.choice(("Tree_1_A_Color1", "Tree_3_A_Color1", "Tree_Bare_1_A_Color1")), side * random.uniform(19.5, 22.5), h + 2, z, random.uniform(0, 6.28), random.uniform(2.0, 2.8))
        fm(random.choice(ROCKS), side * random.uniform(13.4, 14.5), h, z + 3, random.uniform(0, 6.28), random.uniform(3.0, 5.0))

# ---------- Başlangıç ----------
L.top(0, 0, -0.5, 14, 15, depth=6, theme=Q, side="qstrata")                   # x[-7,7] z[7,-8]
L.start(0, 0.1, 4, ry=PI)
L.ent("copy", 3, 0, -3, ability="kaya")
L.ent("hint", 3, 0, -3, hint="ability", size=(5, 3, 5))
L.battery_line((-3, 0, 4), (-3, 0, -4), 4)
rocks(-6, 6, 2, 6, 0, 3)
L.deco("rocktall", -6, 0, -6, 0.5)

# ---------- Öğret: ağır buton → kapı; çatlak zemin ----------
L.top(0, 0, -16.25, 8, 16.5, depth=6, theme=Q, side="qstrata")                # koridor z[-8,-24.5]
wall(-4.5, -3.5, -8, -42, 7, -5); wall(3.5, 4.5, -8, -42, 7, -5)
L.ent("button", 0, 0, -10, targets=["../Gate_1"])
L.ent("gate", 0, 0, -13, size=(7, 6, 0.6), open_offset=(0, -6.2, 0))
L.battery_line((0, 0, -15), (0, 0, -22), 4)
L.top(-2.75, 0, -26, 2.5, 3, depth=1, theme=Q, side="qstrata"); L.top(2.75, 0, -26, 2.5, 3, depth=1, theme=Q, side="qstrata")
L.ent("cracked", 0, -0.3, -26, size=(3, 0.6, 3))
L.top(0, 0, -27.75, 8, 0.5, depth=1, theme=Q, side="qstrata")
wall(-3.5, 3.5, -28, -29, 7, 0)                                # çıkmaz duvar: yol aşağıda
L.ent("hint", 0, 0, -26, hint="ability", size=(4, 3, 4))
L.guide(0, 2, -11)
L.guide(0, 2, -26)
# Alt mağara ve yukarı rampa
L.top(0, -5, -33, 7, 18, depth=2, theme=Q, side="qstrata")                    # z[-24,-42]
L.battery_line((0, -5, -30), (0, -5, -40), 4)
L.ent("prop", 0, -2, -34, kind="lamp", size=1.0)
L.ramp(0, -46, 8, 7, 5, theme=Q, base=-5)
wall(-4.5, -3.5, -42, -50, 2, -5); wall(3.5, 4.5, -42, -50, 2, -5)

# ---------- Sına: zamanlı kapı, ezilecek düşmanlar ----------
L.top(0, 0, -58, 16, 16, depth=6, theme=Q, side="qstrata")                    # meydan z[-50,-66]
L.ent("checkpoint", 5, 0, -52, checkpoint_id="ocak", ry=PI)
L.ent("copy", 2, 0, -52, ability="kaya")
L.ent("button", -5, 0, -54, targets=["../Gate_2"], open_time=6.0)
wall(-8, -3, -66, -67, 7, 0); wall(3, 8, -66, -67, 7, 0)
L.ent("gate", 0, 0, -66.5, size=(6, 6, 0.6), open_offset=(0, -6.2, 0))
L.ent("enemy", -3, 0, -60, kind="vidabocek", patrol=3, speed=1.3, batteries=3)
L.ent("enemy", 3, 0, -62, kind="hurdaci", speed=1.2, batteries=3)
L.ent("enemy", 6.5, 0, -64.5, kind="zipzip", batteries=2)   # kontrol noktasından uzağa (2. oynanış kaydı: doğar doğmaz hasar)
L.ent("crate", -6.5, 0, -64.5, batteries=3)
L.battery_ring((0, 0, -59), 2.5, 6)
L.deco("arrow", -5, 0, -56.5, 0.7, ry=PI / 2)
L.guide(-5, 2, -54)

# ---------- Şaşırt: suyun altındaki yol ----------
L.top(0, 0, -73.5, 12, 13, depth=6, theme=Q, side="qstrata")                  # Q z[-67,-80]
L.ent("copy", 3.5, 0, -77, ability="kaya")
L.top(0, -5, -87, 12, 14, depth=2, theme="sand", side="qstrata")              # havuz tabanı z[-80,-94]
wall(-6.5, -6, -80, -100, 1.5, -5)
wall(6, 6.5, -80, -82, 1.5, -5); wall(6, 6.5, -86, -100, 1.5, -5); wall(6, 6.5, -82, -86, 1.5, -2.6)
L.box(0, 0.7, -88.5, 12, 6.6, 1.0, "stone")                   # bölme duvarı: y[-2.6,4]
L.ent("water", 0, 0, -89, size=(12, 5.2, 18))
L.battery_line((0, -5, -85), (0, -5, -92), 4)
L.ramp(0, -98, 8, 12, 5, theme="sand", base=-5)
L.ent("hint", 0, 0, -82, hint="ability", size=(12, 3, 3))
L.guide(0, -3.5, -88.5)
# Gizli Altın Vida: doğu duvarının altındaki tünelden girilen su altı oyuğu
L.top(8.5, -5, -84, 4, 5, depth=2, theme="sand", side="qstrata")
L.box(8.5, -0.55, -84, 4, 4.1, 5, Q)                           # oyuk tavanı y[-2.6,1.5]
wall(10.5, 11, -81.5, -86.5, -2.6, -5)
wall(6.5, 10.5, -81.5, -82, -2.6, -5); wall(6.5, 10.5, -86, -86.5, -2.6, -5)
L.ent("screw", 8.8, -4.8, -84)

# ---------- Ustalık: dört yetenek sırayla ----------
L.top(0, 0, -105, 12, 6, depth=6, theme=Q, side="qstrata")                    # R z[-102,-108]
L.ent("copy", -3, 0, -104, ability="yay")
L.top(0, 4.5, -113, 12, 6, depth=10, theme=Q, side="qstrata")                 # U1 z[-110,-116] (Yay: 4,5 m)
L.ent("copy", 3, 4.5, -112, ability="balon")
L.battery_arc((0, 4.5, -116.5), (0, 4, -122.5), 5, 2.0)
L.top(0, 4, -126, 12, 6, depth=10, theme="sand", side="qstrata")              # U2 z[-123,-129] (Balon: 7 m)
L.ent("copy", -3, 4, -125, ability="miknatis")
L.ent("checkpoint", 4, 4, -127, checkpoint_id="son", ry=PI)
L.ent("metal", 0, 3, -135.5, size=(2, 2, 2))
L.ent("metal", 0, 3, -143, size=(2, 2, 2))
L.ent("metal", 0, 5, -149, size=(2, 2, 2))
L.battery(0, 4.6, -135.5); L.battery(0, 4.6, -143)
L.top(0, 4, -153, 12, 10, depth=10, theme=Q, side="qstrata")                  # U3 z[-148,-158]
L.ent("copy", -3, 4, -151, ability="kaya")
L.ent("button", 2.5, 4, -153, targets=["../Gate_3"])
wall(-6, -4, -158, -159, 11, 4); wall(4, 6, -158, -159, 11, 4)
L.ent("gate", 0, 4, -158.5, size=(8, 6, 0.6), open_offset=(0, -6.2, 0))
L.ent("enemy", -1, 4, -155, kind="zipzip", batteries=2)
L.top(0, 4, -163, 12, 8, depth=10, theme="grass", side="qstrata")             # U4 z[-159,-167]
L.ent("exit", 0, 4, -164.5)
L.deco("flag", 4.5, 4, -166, 0.8, ry=PI)
L.guide(0, 6.5, -113)
L.guide(0, 6.5, -126)
L.guide(0, 6.5, -143)
rocks(-5, 5, -166, -160, 4, 2)

# =====================================================================================
# Maden süsleri (KayKit Forest + Space Base + Kenney Factory, CC0): kayalar, kamyon, kasalar, ışıklar
# =====================================================================================
rubble(-6, 6, 1, 6, 0, 5)
sb("spacetruck", 5.2, 0, 4.6, 0.4, 3.0); sb("cargo_A_stacked", -5.6, 0, 5.4, 0.2, 1.4)
sb("lights", 6.2, 0, -6.6, 0, 2.2); sb("lights", -6.2, 0, -6.6, 0, 2.2)
sb("lights", 7.0, 0, -51, 0, 2.4); sb("lights", -7.0, 0, -65, 0, 2.4)
sb("containers_A", 6.6, 0, -64.5, 0, 3.0); sb("cargo_B", -7.2, 0, -51.4, 0.5, 1.6)
rubble(-7, 7, -66, -51, 0, 6)
rubble(-5, 5, -79, -68, 0, 4)
fm("Tree_Bare_2_A_Color1", -5.2, 0, -69, 0.6, 1.6)
rubble(-5, 5, -108, -102, 0, 3); rubble(-5, 5, -128, -124, 4, 3)
L.model("kenney/factory/crane.glb", -9.5, -5, -40, PI / 2, 4.0)
L.model("kenney/factory/cone.glb", 2.6, 0, -24, 0, 2.0); L.model("kenney/factory/cone.glb", -2.6, 0, -24, 0, 2.0)
L.model("kenney/factory/warning-orange.glb", 3.0, 0, -10.5, 0, 1.6)
L.label(0, 5, -8.6, "Kaya Ocağı", 64)

# --- Yön işareti: bitişte dev maden kulesi (başlangıçtan görünür) ---
L.top(9, 4, -166, 5, 5, depth=12, theme=Q, side="qstrata")
sb("drill_structure", 9, 4 + 0.87 * 5, -166, 0.3, 5.0)
sb("windturbine_tall", -10, 16, -160, 0, 4.0)
L.kit("star_yellow", 9, 19, -166, s=2.0)

# --- Gizli köşe 1: Yay ile çıkılan Kaya Rafı (başlangıcın batısı) ---
L.ent("copy", -4.5, 0, 1.0, ability="yay")
L.top(-10, 4.5, -1.5, 5, 7, depth=12, theme=Q, side="qstrata")      # x[-12.5,-7.5] z[2,-5]
L.ent("crate", -10.5, 4.5, -3.5, batteries=5)
L.battery_ring((-10, 4.5, -1), 1.4, 7)
fm("Tree_Bare_1_A_Color1", -11.2, 4.5, 1.0, 0.4, 1.6)
L.battery_line((-6.0, 0.6, -1.5), (-6.0, 3.6, -1.5), 2)

# --- Gizli köşe 2: Balonla süzülülen kaya sütunu (U1'in doğusu), trambolinle dönüş ---
L.top(13, 3, -113, 6, 5, depth=12, theme=Q, side="qstrata")        # x[10,16] z[-110.5,-115.5]
L.ent("crate", 11.3, 3, -114.6, batteries=5)
L.battery_ring((13, 3, -113), 1.4, 6)
L.ent("trampoline", 10.9, 3, -111.2, height=4.5)
L.battery_arc((6.4, 4.5, -113), (10.6, 3, -113), 3, 1.0)

L.clouds(14, xr=(-100, 100), zr=(-230, 60), avoid=(-30, 30, -175, 20), low=(-7, -5), high=(25, 45))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("raf", -10, 4.5, -1.5, 5, 7)
L.secret("sutun", 13, 3, -113, 6, 5)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.setpiece("eruption", 5, 0, -52, (-24, -2, -62), size=(12, 4, 4), big=1.6)
L.write()
