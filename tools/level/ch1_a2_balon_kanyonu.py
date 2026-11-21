# Bölüm 1 · Alan 2: Balon Kanyonu (mağaza kalitesinde yeniden yapım, 2026-11-20).
# Tasarım: docs/features/bolum-1/design.md ("Balon Kanyonu" bölümü)
# Gün batımında, katman katman renkli kayalardan oluşan bir kanyon. Yol, uzakta görünen Gün Batımı
# Kayası'na (bitiş kulesi) doğru mesadan mesaya kıvrılır; gökte sıcak hava balonları süzülür.
#   Kanyon Ağzı (Balon) → İlk Süzülüşler (öğret) → 12 m'lik boşluk → Düşen Köprü (sına) → Yay Duvarı (kural 4)
#   → Rüzgâr Kanyonu (şaşırt) → Pervaneler (ustalık) → Gün Batımı Terası (dinlenme) → Büyük Hortum set piece.
# Gizli köşeler: başlangıcın batısındaki Kayıp Balkon (süzülerek in, rüzgârla dön), doğu dibindeki Altın Vida
# çıkıntısı, rüzgâr kanyonunun üstündeki Kartal Yuvası (rüzgârla yüksel, yana süzül).
# Süzülme: 1,5 m/s düşüş, 5 m/s yatay (1 m düşüşte ~3,3 m), 3 sn; yukarı rüzgârda süre harcanmaz.
# Çalıştırma: python3 tools/level/ch1_a2_balon_kanyonu.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_balon", "Balon Kanyonu", "scenes/chapter1/a2_balon_kanyonu.tscn", sky="sunset",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-12, water=-8, seed=22)
PI = math.pi
FLOOR = -9.0          # kanyon dibi (su -8)
STRATA = ("canyon", "sand", "canyon", "quarry")


def mesa(cx, top, cz, sx, sz, theme="sand", lip=True):
    """Yerden yükselen kanyon sütunu: üstte karolu zemin, 1,3 m aşağıda taşan kaya şeridi, altta dibe kadar
    inen gövde. Gövde 'strata' temasıyla boyanır (shader yüksekliğe göre renkli kaya katmanları çizer)."""
    L.top(cx, top, cz, sx, sz, depth=2.0, theme=theme, side="strata")
    y = top - 2.0
    if lip:
        L.box(cx, top - 1.6, cz, sx + 1.0, 1.2, sz + 1.0, "strata")
        y = top - 2.2
    mid = (y + FLOOR) / 2 + 1
    L.box(cx + 0.2, (y + mid) / 2, cz, sx * 0.88, y - mid, sz * 0.88, "strata")
    L.box(cx - 0.2, (mid + FLOOR) / 2, cz, sx * 0.95, mid - FLOOR, sz * 0.95, "strata")


def scatter(cx, top, cz, sx, sz, n):
    """Kanyon süsleri: kaya, taş, kuru ot (çarpışmasız, kenarlardan uzak)."""
    for _ in range(n):
        x = cx + random.uniform(-sx / 2 + 0.8, sx / 2 - 0.8)
        z = cz + random.uniform(-sz / 2 + 0.8, sz / 2 - 0.8)
        L.kenney(random.choice(("rocks", "stones", "plant", "grass")), x, top, z, random.uniform(0, 6.28), random.uniform(1.4, 2.2))


def wind(x, z, top, w=5.0, force=14.0, **kw):
    """Kanyon dibinden 'top' yüksekliğine kadar yukarı rüzgâr (pervane tabanı dipte)."""
    return L.ent("wind", x, FLOOR, z, size=(w, top - FLOOR, w), force=(0, force, 0), **kw)


# =====================================================================================
# Kanyon duvarları: iki yanda basamaklı, renkli katmanlı kayalar (oynanış dışı, yön verir)
# =====================================================================================
for side in (-1, 1):
    for seg, (z0, z1) in enumerate(((20, -30), (-30, -80), (-80, -130), (-130, -185))):
        h_top = (30, 33, 29, 26)[seg]
        off = (seg % 2) * 1.2
        # üç basamaklı teras: alt geniş, üst geride
        for t, (y0, y1, ins) in enumerate(((FLOOR, h_top * 0.45, 0.0), (h_top * 0.45, h_top * 0.8, 2.5), (h_top * 0.8, h_top, 5.0))):
            L.box(side * (24 + ins + off), (y0 + y1) / 2, (z0 + z1) / 2, 10, y1 - y0, abs(z1 - z0) + 0.4, "strata")
        L.top(side * (29 + off), h_top + 0.3, (z0 + z1) / 2, 10, abs(z1 - z0), depth=0.6, theme="sand")
        for k in range(3):
            L.deco("k_tree" if k % 2 else "k_pine", side * (27 + off + k), h_top + 0.3, z0 - 8 - k * 14, 1.0 + 0.2 * k)
    # duvar diplerinde kaya yığınları
    for z in range(10, -180, -22):
        L.kenney("rocks", side * (17.5 + random.uniform(0, 2)), FLOOR + 1.0, z + random.uniform(-4, 4), random.uniform(0, 6.28), 4.0)

# =====================================================================================
# 0 · KANYON AĞZI (başlangıç)                                       x[-7,7] z[8,-4]
# =====================================================================================
mesa(0, 20, 2, 14, 12)
L.start(0, 20.1, 6, ry=PI)
L.ent("copy", 2.5, 20, -0.5, ability="balon")
L.ent("hint", 2.5, 20, -0.5, hint="ability", size=(5, 3, 5))
L.ent("hint", 0, 20, -3, hint="hold_jump", size=(14, 3, 2.5))
L.battery_line((-2, 20, 5), (-2, 20, -2.5), 4)
L.ent("crate", -5, 20, -2.5, batteries=3)
L.ent("crate", 5.5, 20, 6.5, batteries=2)
L.rock(5, 20, 3.5, 0.8)
L.kit("signage_arrow_stand_yellow", 1.0, 20, -3.4, ry=PI / 2)
L.kit("flag_A_red", -6.2, 20, 7.2)
scatter(0, 20, 2, 14, 12, 6)
L.guide(0, 22, -4)
# Batıya inen pil sırası: Kayıp Balkon'u ima eder
L.battery_arc((-7.5, 20, 3.5), (-13, 14, 3.5), 4, 1.5)

# --- Gizli köşe 1: Kayıp Balkon (batıya süzül, rüzgârla geri yüksel) ---
mesa(-14, 13, 1, 5, 6, theme="canyon")                   # x[-16.5,-11.5] z[-2,4]
L.battery_ring((-14, 13, 1), 1.5, 8)
L.ent("crate", -15, 13, 3, batteries=5)
wind(-9.3, 1, 24, w=2.6, force=14)                         # balkon ile başlangıç kayası arasında
L.battery_line((-9.3, 16, 1), (-9.3, 22, 1), 3)
L.kit("flag_C_blue", -15.8, 13, -1.2)

# =====================================================================================
# 1 · ÖĞRET: İLK SÜZÜLÜŞLER (4 m, 7 m)
# =====================================================================================
mesa(1, 19, -11, 8, 6)                                    # M1 x[-3,5] z[-8,-14]
L.battery_arc((0.5, 20, -4.5), (1, 19, -7.5), 3, 1.2)
scatter(1, 19, -11, 8, 6, 3)
mesa(5, 17, -25, 10, 8)                                   # M2 x[0,10] z[-21,-29]
L.battery_arc((3, 19, -14.5), (5, 17, -20.5), 5, 2.2)
L.ent("checkpoint", 8.5, 17, -22.5, checkpoint_id="kanyon1", ry=PI)
L.ent("enemy", 3, 17, -26, kind="zipzip", batteries=2)
L.ent("crate", 1.5, 17, -28, batteries=2)
scatter(5, 17, -25, 10, 8, 4)
L.battery_ring((5, 17, -25), 2.2, 6)
L.guide(3, 19.5, -17)

# =====================================================================================
# 2 · SINA: 12 m'lik uzun süzülüş, sonra düşen köprü
# =====================================================================================
mesa(5, 14, -44.5, 10, 7)                                 # M3 x[0,10] z[-41,-48]
L.battery_arc((5, 17, -29.5), (5, 14, -40.5), 7, 3.0)
L.ent("crate", 8.5, 14, -43, batteries=3)
scatter(5, 14, -44.5, 10, 7, 3)
L.guide(5, 17, -35)
for i, (x, z) in enumerate(((4, -52), (2, -56.5), (0, -61), (-2, -65.5))):
    L.ent("platform", x, 13.75, z, kind="fall", size=(3, 0.5, 3), color=(0.95, 0.62, 0.38, 1))
    L.battery(x, 14, z)
mesa(-3, 14, -73, 12, 8)                                  # M4 x[-9,3] z[-69,-77]
L.ent("checkpoint", 1, 14, -71, checkpoint_id="dusen", ry=PI)
L.ent("copy", -7, 14, -71.5, ability="yay")
L.ent("enemy", -4, 14, -74, kind="vidabocek", patrol=2.0, speed=1.2, batteries=2)
scatter(-3, 14, -73, 12, 8, 4)

# --- Gizli köşe 2: doğu dibindeki Altın Vida çıkıntısı (dönüş rüzgârla) ---
mesa(14, 7, -51, 4, 4, theme="yellow")                    # x[12,16] z[-49,-53]
L.ent("screw", 14, 7.2, -51.5)
L.kit("star_yellow", 14, 10, -51.5, s=1.2)
wind(14, -46, 21, w=3.0, force=14)                         # z[-44.5,-47.5]: tepeden batıya süzül → M3
L.battery_line((14, 9, -46), (14, 16, -46), 3)
L.battery_arc((5.5, 14.5, -52.5), (12.5, 7.5, -51), 3, 1.0)   # düşen köprüden ipucu

# =====================================================================================
# 3 · YAY DUVARI (önceki alanın yeteneği, kural 4): 4,5 m
# =====================================================================================
mesa(-3, 18.5, -83, 12, 8)                                # M5 x[-9,3] z[-79,-87]
L.battery_line((-3, 14.5, -77.6), (-3, 18.0, -77.6), 3)
L.ent("copy", 1, 18.5, -81, ability="balon")              # balon yeniden
L.ent("enemy", -6, 18.5, -84, kind="vidabocek", patrol=2.0, speed=1.3, batteries=2)
L.kit("signage_arrow_stand_red", -3, 18.5, -86.6, ry=PI / 2)
scatter(-3, 18.5, -83, 12, 8, 3)
L.battery_line((-8, 18.5, -81), (2, 18.5, -81), 5)
L.guide(-3, 21, -80)

# =====================================================================================
# 4 · ŞAŞIRT: RÜZGÂR KANYONU (balonla rüzgâra gir, yüksel, ileri süzül)
# =====================================================================================
wind(-3, -92.5, 25)
wind(-3, -98.5, 25)
L.battery_line((-3, 21, -92.5), (-3, 25, -92.5), 3)
L.battery_line((-3, 22, -98.5), (-3, 26, -98.5), 3)
mesa(-3, 23, -108, 12, 8)                                 # M6 x[-9,3] z[-104,-112]
L.ent("checkpoint", 1, 23, -106, checkpoint_id="ruzgar", ry=PI)
L.ent("copy", -7, 23, -106, ability="balon")
scatter(-3, 23, -108, 12, 8, 4)
L.battery_ring((-3, 23, -108.5), 2.5, 8)
L.guide(-3, 24, -95)

# --- Gizli köşe 3: Kartal Yuvası (ikinci rüzgârın tepesinden doğuya süzül) ---
mesa(8, 23.5, -98.5, 3.5, 3.5, theme="canyon", lip=False)
L.battery_ring((8, 23.5, -98.5), 1.0, 6)
L.ent("crate", 8, 23.5, -99.6, batteries=5)
L.kit("flag_A_yellow", 9.2, 23.5, -97.4)

# =====================================================================================
# 5 · USTALIK: AÇILIP KAPANAN PERVANELER
# =====================================================================================
wind(-3, -117, 26, w=4.0, force=12, cycle=3.0, offset=0.0)
mesa(-3, 18, -123, 3, 3, theme="canyon", lip=False)      # ara sütun (4 m aşağıda)
L.battery_line((-3, 18, -122), (-3, 18, -124), 2)
L.battery_arc((-3, 23, -113), (-3, 19, -121.5), 3, 2.0)
wind(-3, -129.5, 28, w=4.0, force=15, cycle=3.0, offset=1.5)
L.battery_line((-3, 21, -129.5), (-3, 25, -129.5), 3)
L.guide(-3, 24, -118)

# =====================================================================================
# 6 · GÜN BATIMI TERASI (dinlenme) ve BÜYÜK HORTUM ile bitiş kayasına
# =====================================================================================
mesa(-3, 22, -139, 12, 8)                                 # M7 x[-9,3] z[-135,-143]
L.ent("checkpoint", 1, 22, -137, checkpoint_id="teras", ry=PI)
L.ent("copy", -7, 22, -137, ability="balon")
L.battery_ring((-3, 22, -139), 2.5, 8)
L.kit("arch_wide_red", -3, 22, -142.6)
L.label(-3, 27, -143, "Gün Batımı Terası", 60)
scatter(-3, 22, -139, 12, 8, 3)
# Büyük Hortum: dipten 45 m'ye kadar güçlü rüzgâr; Bip yükselir, kayanın tepesine süzülür
wind(-3, -148, 45, w=6.0, force=18)
L.ent("hint", -3, 22, -142, hint="hold_jump", size=(8, 3, 2))
L.battery_line((-3, 25, -148), (-3, 42, -148), 7)
L.guide(-3, 30, -146)
mesa(-3, 40, -157.5, 9, 7, theme="sand")                  # Gün Batımı Kayası x[-7.5,1.5] z[-154,-161]
L.ent("exit", -3, 40, -158)
L.kit("signage_finish_wide", -3, 40, -155)
L.kit("flag_A_red", -7, 40, -160.5); L.kit("flag_A_yellow", 1, 40, -160.5)
L.kit("star_yellow", -3, 45.5, -159, s=2.2)

# =====================================================================================
# Manzara: sıcak hava balonları, bulutlar
# =====================================================================================
for (x, y, z, c, s) in ((-14, 34, -30, (0.95, 0.35, 0.3, 1), 1.0), (16, 30, -70, (0.3, 0.6, 0.95, 1), 0.9),
                        (-12, 38, -120, (0.98, 0.78, 0.25, 1), 1.1), (12, 48, -170, (0.55, 0.85, 0.4, 1), 1.0),
                        (30, 40, 10, (0.85, 0.45, 0.85, 1), 1.3), (-34, 44, -90, (0.95, 0.55, 0.25, 1), 1.4)):
    L.ent("prop", x, y, z, kind="balloon", size=s, color=c, parent="Decor")
L.clouds(18, xr=(-110, 110), zr=(-230, 60), avoid=(-30, 30, -190, 25), low=(-6, -3), high=(36, 55))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("balkon", -14, 13, 1, 5, 6)
L.secret("vida", 14, 7, -51, 4, 4)
L.secret("kartal", 8, 23.5, -98.5, 3.5, 3.5)
L.write()
