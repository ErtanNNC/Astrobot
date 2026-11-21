# Bölüm 5 (bonus) · Alan 4: Top Adaları (yeni, 2026-11-22). Tasarım: docs/features/bolum-5/design.md
# Fikir: adadan adaya FIRLATMA TOPLARI ile gidilir (ana yolda zorunlu "vay" anı; docs/features/vay-anlari/design.md).
#   Kalkış Adası → top A → Kum Adası (düşmanlar) → top B → Çimen Adası (trambolinle çıkıntıya) → top C →
#   ZİNCİR: C, Bip'i doğrudan D'nin içine atar, D de E'ye, E de Yıldız Adası'na (üç top art arda, kontrolsüz uçuş).
# Gizli köşe: Kum Adası'ndaki mor kaideli toptan Vida Adacığı'na (Altın Vida), oradan geri.
# Alan köşeli tasarlandı (toplar her yöne atabildiği için L.turns gerekmiyor).
# Çalıştırma: python3 tools/level/ch5_e3b_top_adalari.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch5_top", "Top Adaları", "scenes/chapter5/e3b_top_adalari.tscn", sky="day",
          music="res://assets/audio/opengameart/superhero.ogg", kill_height=-14, water=-10, seed=55)
ARC = 6.0


def shot(pos, target, n=6, arc=ARC, secret=False):
    """Top + uçuş yolundaki piller (cannon.gd ile aynı kavis: başlangıç pos+1,6 m, tepe = yüksek uç + arc)."""
    L.cannon(pos[0], pos[1], pos[2], target, arc=arc, secret=secret)
    fy, ty = pos[1] + 1.6, target[1]
    top = max(fy, ty) + arc
    for i in range(n):
        k = (i + 1.5) / (n + 2)
        y = fy + (ty - fy) * k + (top - (fy + ty) / 2) * 4 * k * (1 - k)
        L.battery(pos[0] + (target[0] - pos[0]) * k, y - 0.3, pos[2] + (target[2] - pos[2]) * k)


def palms(pts, y):
    for (x, z, s) in pts:
        L.tree(x, y, z, s)


# =====================================================================================
# 0 · KALKIŞ ADASI                                                   x[-7,7] z[6,-6]
# =====================================================================================
L.island(0, 0, 0, 14, 12, "grass")
L.start(0, 0.1, 3.5, ry=PI)
L.battery_line((-3, 0, 3), (-3, 0, -3), 4)
L.ent("crate", 5, 0, 3.5, batteries=3)
palms(((-5.6, 4.6, 1.0), (5.8, -4.4, 0.9)), 0)
L.label(0, 5, -6.5, "Top Adaları", 64)
L.guide(0, 2, -3)
L.vista(0, 0, 1.0, (4, 40, -146), "Yıldız Adası", size=(14, 4, 2))
shot((0, 0, -4.2), (18, 8, -28))

# =====================================================================================
# 1 · KUM ADASI (düşmanlar, kontrol noktası)                         x[12,24] z[-25,-37]
# =====================================================================================
L.island(18, 8, -31, 12, 12, "sand")
L.ent("checkpoint", 14, 8, -29, checkpoint_id="kum", ry=PI)
L.ent("enemy", 19, 8, -32, kind="vidabocek", patrol=2.5, speed=1.2, batteries=2)
L.ent("enemy", 15, 8, -34.5, kind="zipzip", batteries=2)
L.ent("crate", 22.5, 8, -27, batteries=3)
L.battery_ring((18, 8, -31), 3.2, 8)
palms(((23, -36, 1.0),), 8)
L.guide(18, 10, -34)
shot((16.5, 8, -35.4), (-10, 16, -58))
# --- Gizli köşe: mor kaideli yan top → Vida Adacığı (Altın Vida), oradan geri ---
shot((22.6, 8, -31.5), (38, 14, -20), n=4, secret=True)
L.island(38.5, 14, -21, 6, 6, "grass", skirt=False)
L.ent("screw", 40, 14.1, -22.5)
L.ent("crate", 36.6, 14, -22.8, batteries=5)
L.cannon(40.2, 14, -19.4, (16.5, 8, -27.5), secret=True)
L.secret("vida_adacigi", 38.5, 14, -21, 6, 6)

# =====================================================================================
# 2 · ÇİMEN ADASI (Atıcı, trambolinle çıkıntıya)                     x[-16,-4] z[-55,-67]
# =====================================================================================
L.island(-10, 16, -61, 12, 12, "grass")
L.ent("checkpoint", -14, 16, -59, checkpoint_id="cimen", ry=PI)
# İniş noktası (-10, -58) güvenli kalsın: düşmanlar adanın öbür ucunda, Atıcı yok
L.ent("enemy", -6.5, 16, -64.5, kind="zipzip", batteries=2)
L.ent("enemy", -13, 16, -64, kind="dikenli", patrol=1.5, speed=1.0, batteries=2)
L.battery_line((-13, 16, -57), (-7, 16, -57), 4)
L.ent("trampoline", -10, 16, -65.2, height=5.5)
L.top(-10, 20.5, -70.5, 7, 6, depth=1.2, theme="yellow")           # çıkıntı z[-67.5,-73.5]
L.battery_line((-10, 18, -66), (-10, 21.5, -68), 3)
L.kit("flag_A_red", -13, 20.5, -73); L.kit("flag_A_blue", -7, 20.5, -73)
L.guide(-10, 22, -68)

# =====================================================================================
# 3 · ZİNCİR: C → D → E → Yıldız Adası (her top Bip'i bir sonrakinin içine atar)
# =====================================================================================
D = (14, 24, -92)
E = (-12, 30, -116)
F = (4, 34, -143)
shot((-10, 20.5, -71.6), D, n=5)
L.top(D[0], D[1], D[2], 4.5, 4.5, depth=1.0, theme="red")
shot(D, E, n=5)
L.top(E[0], E[1], E[2], 4.5, 4.5, depth=1.0, theme="blue")
shot(E, F, n=5)

# =====================================================================================
# 4 · YILDIZ ADASI (bitiş)                                            x[-3,11] z[-139,-153]
# =====================================================================================
L.island(4, 34, -146, 14, 14, "grass")
L.ent("checkpoint", 1.5, 34, -146.5, checkpoint_id="yildiz", ry=PI)
L.battery_ring((4, 34, -146), 4.0, 10)
L.ent("exit", 4, 34, -150.5)
L.kit("signage_finish_wide", 4, 34, -148.2)
L.kit("star_yellow", 4, 42, -151, s=4.0)
L.kit("flag_A_yellow", 0.5, 34, -152); L.kit("flag_A_red", 7.5, 34, -152)
palms(((-2, -151.8, 1.0), (10, -151.6, 0.9)), 34)
L.setpiece("fireworks", 4, 34, -144, (4, 42, -156), size=(10, 5, 4))

# =====================================================================================
# Manzara: uzak adacıklar, balonlar, balina, bulutlar
# =====================================================================================
for (x, y, z, w) in ((-28, 4, -20, 8), (36, 10, -70, 9), (-34, 18, -100, 8), (30, 26, -130, 9), (-20, 30, -160, 8)):
    L.island(x, y, z, w, w, "grass", skirt=False)
    L.tree(x - 1, y, z + 1, 1.2)
for (x, y, z, c) in ((-14, 14, -30, (0.95, 0.35, 0.3, 1)), (26, 22, -56, (0.3, 0.6, 0.95, 1)), (-24, 30, -86, (0.98, 0.78, 0.25, 1)), (22, 38, -120, (0.6, 0.85, 0.4, 1))):
    L.ent("prop", x, y, z, kind="balloon", size=0.9, color=c, parent="Decor")
L.ent("prop", -30, -10, -60, kind="whale", size=1.4, parent="Decor")
L.clouds(22, xr=(-90, 90), zr=(-220, 40), avoid=(-20, 44, -160, 10), low=(-8, -4), high=(44, 60))
L.write()
