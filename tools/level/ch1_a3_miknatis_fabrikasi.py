# Bölüm 1 · Alan 3: Mıknatıs Fabrikası (mağaza kalitesinde yeniden yapım, 2026-11-21).
# Tasarım: docs/features/bolum-1/design.md ("Mıknatıs Fabrikası" bölümü)
# Denizin üstünde, ayaklar üzerinde duran bir fabrika. Zeminler perçinli çelik + Kenney Factory Kit döşemeleri,
# her yerde çalışan makineler: konveyörler, robot kollar, huniler, borular, ekranlar (Kenney Factory Kit, CC0).
# Yön işareti: sonda uzaktan görünen DEV MIKNATIS VİNCİ.
#   Fabrika Kapısı → Mıknatıs Duvarı (öğret) → Zincir Köprü (sına) → Konveyör Hattı → Levha Duvarı
#   → Yay ↔ Mıknatıs (şaşırt) → Dönen Çarklar (ustalık) → Vinç Terası (bitiş).
# Gizli köşeler: Depo (levha duvarının doğusunda, mıknatısla), Altın Vida bloğu (konveyörün yanında boşlukta),
# Vinç Kulesi (bitişte metal levhalarla vincin tepesine).
# Mıknatıs: menzil 7 m; yapışıkken Yetenek = sıradaki metale geç, Zıpla = üst kenara tırman.
# Çalıştırma: python3 tools/level/ch1_a3_miknatis_fabrikasi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_miknatis", "Mıknatıs Fabrikası", "scenes/chapter1/a3_miknatis_fabrikasi.tscn", sky="factory",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-12, water=-8, seed=33)
PI = math.pi
# Yol üç yerde döner (tasarım koordinatları dümdüz kalır): zincir köprüde sola, levha duvarından sonra sağa,
# çarklardan önce yine sola. Pivotlar boşluklarda, yol ekseninde.
L.turns([(0, -25, 40), (0, -85, -70), (0, -126.5, 50)])
K = "kenney/factory/"
SEA = -8.0


def km(model, x, y, z, ry=0.0, s=2.0):
    """Kenney Factory Kit süsü (çarpışmasız)."""
    L.model(K + model + ".glb", x, y, z, ry, s)


def deck(cx, top, cz, sx, sz, depth=1.2, legs=True, wall=False):
    """Fabrika zemini: perçinli çelik kutu + üstüne Kenney döşemeleri; altında sarı çelik ayaklar (denize iner).
    wall=True: gövde denize kadar dolu (mıknatısla tırmanılan duvarlar)."""
    d = top - SEA if wall else depth
    L.box(cx, top - d / 2, cz, sx, d, sz, "factory")
    # kenarlarda sarı şerit (oyuncak fabrika havası; KayKit sarı blok, ince, çarpışmasız)
    for ez in (-1, 1):
        L.kit("platform_1x1x1_yellow", cx, top - 0.95, cz + ez * (sz / 2 - 0.15), 0, (sx + 0.04, 1.0, 0.32))
    for ex in (-1, 1):
        L.kit("platform_1x1x1_yellow", cx + ex * (sx / 2 - 0.15), top - 0.95, cz, 0, (0.32, 1.0, sz))
    if legs and not wall:
        h = top - depth - SEA
        for ex in (-1, 1):
            for ez in (-1, 1):
                L.model(K + "structure-yellow-tall.glb", cx + ex * (sx / 2 - 0.6), SEA, cz + ez * (sz / 2 - 0.6), 0, (2.0, h / 2, 2.0))


def metal(x, y, z, sx=2, sy=2, sz=2):
    return L.ent("metal", x, y, z, size=(sx, sy, sz))


def gear_wall(x, y, z, size=1.4, spin=0.5):
    L.ent("prop", x, y, z, kind="gear", size=size, spin=spin, ry=PI / 2)


def line(x, y, z, n, ry=0.0, s=2.0):
    """Üstünde kutular giden süs konveyör hattı."""
    dx, dz = -math.sin(ry) * 2 * s, -math.cos(ry) * 2 * s
    for i in range(n):
        km("conveyor-long", x + dx * i, y, z + dz * i, ry + PI / 2, s)
        if i % 2 == 0:
            km(random.choice(("box-small", "box-large", "box-long")), x + dx * i, y + 0.4 * s, z + dz * i, random.uniform(0, 1), s * 0.8)


# =====================================================================================
# Fabrika binaları (arka plan): pencereli çelik duvarlar, dev dişliler, bacalar
# =====================================================================================
# Binalar dönüş noktalarında bölünür, dönüşün iç tarafında kısalır (L.wall_spans); her parça kendi yol kesimiyle döner
for side, z0, z1 in L.wall_spans(14, -172):
    h = 18 + int((14 - z0) / 186 * 12)
    L.box(side * 20, (h + SEA) / 2, (z0 + z1) / 2, 8, h - SEA, abs(z1 - z0), "factory")
    for z in range(int(z0) - 3, int(z1), -6):
        km("structure-window-wide", side * 15.9, h - 9.5, z, -side * PI / 2, 3.0)
    gear_wall(side * 15.6, h - 3, (z0 + z1) / 2, 2.4, 0.3 * side)
for side in (-1, 1):
    for z, hh in ((-20, 36), (-80, 42), (-140, 48)):
        L.box(side * 26, hh / 2, z, 4, hh, 4, "factory")
        L.box(side * 26, hh + 0.4, z, 4.6, 0.8, 4.6, "red")
        L.deco("cloud2", side * 26, hh + 2.5, z, 0.5, parent="Clouds")

# =====================================================================================
# 0 · FABRİKA KAPISI (başlangıç)                                    x[-7,7] z[7,-10]
# =====================================================================================
deck(0, 0, -1.5, 14, 17, depth=4)
L.start(0, 0.1, 4, ry=PI)
L.ent("copy", 3, 0, -2, ability="miknatis")
L.ent("hint", 3, 0, -2, hint="ability", size=(5, 3, 5))
L.battery_line((-3, 0, 4), (-3, 0, -3), 4)
L.ent("crate", -5, 0, 5, batteries=3)
L.ent("crate", -6, 0, 3.8, batteries=2)
line(-5.8, 0, -1, 3, 0, 1.4)
km("robot-arm-a", -4.2, 0, -5.8, 0.6, 2.2); km("machine-window", 5.6, 0, 5.2, PI, 2.0)
km("hopper-high-round", 6.0, 0, -8.6, 0, 2.0); km("screen-wide", 1.0, 0, -9.2, 0, 1.6)
km("warning-orange", 6.4, 0, 1.2, 0, 1.6); km("cone", 5.6, 0, -0.2, 0, 2.0)
L.ent("prop", 0, 4, 2, kind="lamp", size=1.2)
L.label(0, 5.5, -10.5, "Mıknatıs Fabrikası", 64)

# =====================================================================================
# 1 · ÖĞRET: metal tutamağa çekil, üstüne tırman (5 m duvar)
# =====================================================================================
deck(0, 5, -16, 14, 12, wall=True)                         # C1 z[-10,-22]
metal(0, 6, -11)                                            # kenardaki tutamak (y 5..7)
L.ent("hint", 0, 0, -8, hint="ability", size=(8, 3, 3))
L.battery_line((0, 1.5, -8.8), (0, 4.5, -9.2), 3)
L.guide(0, 4, -9)
km("pipe-large-long", -5, 5, -20.5, 0, 2.0); km("pipe-large-valve", -1, 5, -20.5, 0, 2.0)
km("machine", 5.4, 5, -18.5, -PI / 2, 2.0)
L.battery_ring((-2, 5, -16), 1.6, 6)

# =====================================================================================
# 2 · SINA: ZİNCİR KÖPRÜ (her boşluk 5,5 m, normal zıplama yetmez)
# =====================================================================================
for z in (-28.5, -36, -43.5):
    metal(0, 4, z)
    L.battery(0, 5.6, z)
    km("structure-yellow-tall", 0, SEA, z, 0, (2.0, 5.5, 2.0))          # bloğun ayağı
metal(0, 6, -51)                                            # iniş tutamağı
deck(0, 5, -55, 12, 10)                                     # P1 z[-50,-60]
L.ent("checkpoint", 4, 5, -56, checkpoint_id="zincir", ry=PI)
L.ent("crate", -4, 5, -57.5, batteries=3)
km("robot-arm-b", -4.6, 5, -52.6, 2.2, 2.2); km("screen-wide", 4.8, 5, -59.4, 0, 1.4)
L.guide(0, 7.5, -36)
# altta denizde çalışan konveyör hattı (manzara)
line(-8, -6.5, -26, 10, 0, 2.0)

# =====================================================================================
# 3 · KONVEYÖR HATTI (geri iter) ve Hurdacı
# =====================================================================================
L.ent("platform", 0, 4.75, -66, ry=PI, kind="conveyor", size=(6, 0.5, 12), belt_speed=3.0)
L.ent("enemy", 1.5, 5.2, -68, kind="hurdaci", speed=1.4, batteries=3)
L.battery_line((-1.5, 5, -62), (-1.5, 5, -70), 4)
km("structure-yellow-tall", -3.2, 4.5, -61, 0, (1.5, 1.6, 1.5)); km("structure-yellow-tall", 3.2, 4.5, -61, 0, (1.5, 1.6, 1.5))
km("scanner-high", 0, 4.75, -66, 0, (3.4, 2.2, 1.6))
deck(0, 5, -73, 14, 2, wall=True)                           # duvar dibi çıkıntı z[-72,-74]

# --- Gizli köşe 2: Altın Vida, konveyörün yanında boşlukta duran metal blok ---
metal(9, 9.5, -64)
L.ent("screw", 9, 10.6, -64)
km("crane-magnet", 9, 10.5, -64, 0, 2.6)
L.battery_arc((3.5, 6, -64), (8, 10.5, -64), 3, 1.0)

# =====================================================================================
# 4 · LEVHA DUVARI: dikey metal levhalarla 7 m'lik duvara tırmanış
# =====================================================================================
deck(0, 12, -79, 14, 10, wall=True)                         # C2 z[-74,-84]
metal(0, 6.8, -73.5, 2, 1.6, 1)
metal(0, 9.8, -73.5, 2, 1.6, 1)
metal(0, 12.05, -73.5, 2, 1.1, 1)
L.battery_line((1.6, 7, -72.6), (1.6, 11.5, -72.6), 3)
L.ent("checkpoint", 4, 12, -80, checkpoint_id="duvar", ry=PI)
L.ent("enemy", -3, 12, -81, kind="zipzip", batteries=2)
km("hopper-square", -5.5, 12, -76.5, 0, 2.0); km("machine-fortified", 5.6, 12, -83, PI, 2.0)
L.guide(0, 9, -72)

# --- Gizli köşe 1: Depo (doğuda; kenardaki metal tutamağa çekil, üstüne tırman) ---
deck(14, 12, -79.5, 5, 6)                                   # x[11.5,16.5]
metal(10.6, 11.0, -79.5, 1.6, 2, 2)                         # deponun batı yüzünde tutamak
L.ent("crate", 14, 12, -81.5, batteries=5)
L.battery_ring((14, 12, -79), 1.3, 7)
km("box-large", 15.4, 12, -77.6, 0.3, 2.0); km("box-small", 12.8, 12, -77.5, 1.0, 2.0)
L.battery_line((7.2, 12.6, -79.5), (9.6, 12.6, -79.5), 2)

# =====================================================================================
# 5 · ŞAŞIRT: Yay ↔ Mıknatıs
# =====================================================================================
L.ent("copy", -3, 12, -82, ability="yay")
deck(0, 16.5, -89, 12, 6, wall=True)                        # R z[-86,-92] (4,5 m yukarı)
L.ent("copy", 3, 16.5, -88, ability="miknatis")
metal(0, 15.5, -97.5)
metal(0, 15.5, -105)
metal(0, 17.5, -111)
for z in (-97.5, -105):
    km("structure-yellow-tall", 0, SEA, z, 0, (2.0, 11.2, 2.0))
L.battery_arc((0, 16.5, -92.5), (0, 16.5, -96.5), 3, 1.5)
L.battery_arc((0, 16.5, -98.5), (0, 16.5, -104), 4, 1.5)
deck(0, 16.5, -113, 12, 6, wall=True)                       # S z[-110,-116]
L.ent("copy", -3, 16.5, -114, ability="yay")
L.ent("checkpoint", 4, 16.5, -114, checkpoint_id="dongu", ry=PI)
deck(0, 21, -121, 12, 6, wall=True)                         # T z[-118,-124]
L.ent("copy", 3, 21, -122, ability="miknatis")
L.ent("enemy", -3, 21, -121, kind="hurdaci", speed=1.3, batteries=2)
km("robot-arm-a", -5, 21, -123.4, 0.3, 2.0); km("warning-traffic", 5.4, 21, -119, 0, 2.0)
L.guide(0, 19, -100)
L.guide(0, 23, -121)

# =====================================================================================
# 6 · USTALIK: DÖNEN METAL ÇARKLAR
# =====================================================================================
L.ent("platform", 3, 21.7, -131, kind="spin", size=(5, 0.6, 5), duration=6.0, metal=True)
L.ent("platform", -3, 23.7, -139, kind="spin", size=(5, 0.6, 5), duration=-5.0, metal=True)
L.ent("platform", 3, 25.7, -147, kind="spin", size=(5, 0.6, 5), duration=6.0, metal=True)
L.battery(3, 22, -131); L.battery(-3, 24, -139); L.battery(3, 26, -147)
for (x, y, z) in ((3, 21.4, -131), (-3, 23.4, -139), (3, 25.4, -147)):
    km("structure-yellow-tall", x, SEA, z, 0, (2.4, (y - SEA) / 2, 2.4))
L.guide(0, 25, -139)

# =====================================================================================
# 7 · VİNÇ TERASI (bitiş) ve DEV MIKNATIS VİNCİ (yön işareti)
# =====================================================================================
deck(0, 26, -156, 12, 8)                                    # U z[-152,-160]
L.ent("exit", 0, 26, -157.5)
L.ent("prop", -4.5, 29, -159, kind="lamp", size=1.2)
L.ent("checkpoint", -4, 26, -153, checkpoint_id="vinc", ry=PI)
L.battery_ring((0, 26, -156), 2.6, 8)
L.box(17, 9, -166, 6, 34, 6, "factory")                    # vinç kaidesi
km("crane", 17, 26, -166, PI, 6.0)                          # dev vinç: kolu yola doğru uzanır (uzaktan görünür)
km("crane-magnet", 17, 33, -150, 0, 5.0)
km("indicator-special-arrow", 0, 26.01, -153, PI, 2.0)
L.kit("signage_finish_wide", 0, 26, -154.6)

# --- Gizli köşe 3: Vinç Kulesi (terasın doğusu; metal levhalarla yukarı) ---
deck(10.5, 33, -153, 4, 4)                                  # x[8.5,12.5] z[-151,-155]
metal(8.0, 27.6, -153, 1, 1.6, 2)
metal(8.0, 30.6, -153, 1, 1.6, 2)
metal(8.0, 33.05, -153, 1, 1.1, 2)
L.ent("crate", 10.5, 33, -153.6, batteries=5)
L.battery_ring((10.5, 33, -153), 1.2, 6)
L.kit("flag_A_yellow", 11.8, 33, -154.6)

for i in range(6):
    L.ent("prop", random.choice((-6.5, 6.5)), random.uniform(6, 20), -20 - i * 22, kind="lamp", size=1.0)

L.clouds(14, xr=(-100, 100), zr=(-220, 60), avoid=(-30, 30, -170, 20), low=(-6, -3), high=(35, 50))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("depo", 14, 12, -79.5, 5, 6)
L.secret("vinc", 10.5, 33, -153, 4, 4)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
# Vinç Terası'ndaki toptan batıdaki asılı güverteye, oradan geri
L.cannon(-4.6, 26, -158.6, (-17.5, 34, -157.5))
deck(-16.5, 34, -156, 6, 6)
L.battery_ring((-16.5, 34, -156), 1.8, 8)
L.ent("crate", -18.6, 34, -154.2, batteries=5)
L.cannon(-14.6, 34, -154.4, (2.5, 26, -155.8))
L.write()
