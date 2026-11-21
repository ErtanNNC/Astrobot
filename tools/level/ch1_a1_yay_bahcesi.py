# Bölüm 1 · Alan 1: Yay Bahçesi (mağaza kalitesinde yeniden yapım, 2026-11-20).
# Tasarım: docs/features/bolum-1/design.md ("Yay Bahçesi" bölümü)
# Yol, uzakta görünen bitiş kulesine doğru kıvrılan katmanlı yüzen adalardan geçer:
#   Bahçe Kapısı → Yaylı Teraslar (öğret) → Basamak Taşları (ilk çukurlar) → Hareketli köprü ve asansör (sına)
#   → Çiçek Tepesi (dinlenme, manzara) → Zıplayan Yaylar (şaşırt: trambolinler platformla gider)
#   → Ezme Bahçesi (Yay ile düşman ezme) → Dönen Kule (ustalık) → Dev Yay ile bitiş kulesine fırlatılış.
# Gizli köşeler: başlangıç adasının altındaki mağara, terasın yanındaki taş sütun (kenara tutunma),
# gökteki Altın Vida adası (hareketli trambolinden).
# Kurallar: zorunlu boşluklar ≤ 3,2 m (normal zıplama ~%70), Yay ile çıkılan basamaklar ≤ 4,5 m.
# Çalıştırma: python3 tools/level/ch1_a1_yay_bahcesi.py
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_yay", "Yay Bahçesi", "scenes/chapter1/a1_yay_bahcesi.tscn", sky="day",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-14, water=-10, seed=11)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar boşluklarda, yol ekseninde. Bkz. lvl.py TURNS
L.turns([(-1, -62, 35), (-1, -108.5, -45)])
PI = math.pi


def flowerbed(x, y, z, w=2.0, d=2.0, color="flowers"):
    """Çitle çevrili küçük çiçek tarhı (süs, çarpışmasız)."""
    for i in range(int(w)):
        L.kenney("fence-straight", x - w / 2 + 0.5 + i, y, z - d / 2, 0, 1.0)
    for k in range(3):
        L.kenney(color, x - w / 2 + 0.5 + k * (w - 1) / 2, y, z, k, 2.0)


# =====================================================================================
# 0 · BAHÇE KAPISI (başlangıç adası)                                    x[-9,9] z[8,-8]
# =====================================================================================
L.island(0, 0, 0, 18, 16, "grass", skirt=True)
L.start(0, 0.1, 5, ry=PI)
L.ent("copy", 3, 0, -2, ability="yay")
L.ent("hint", 3, 0, -2, hint="ability", size=(5, 3, 5))
L.battery_line((0, 0, 3), (0, 0, -6), 5)
L.ent("crate", -6, 0, -5, batteries=3)
L.ent("crate", -7.2, 0, -3.8, batteries=2)
L.tree(-7, 0, 6, 1.0); L.tree(7.5, 0, 5.5, 0.9, True); L.tree(-7.5, 0, -6.5, 0.8)
L.bush(7.5, 0, -2, 0.9)
L.kit("signage_arrow_stand_yellow", 1.2, 0, -6.8, ry=PI / 2)
L.kit("pipe_straight_A_green", 7.6, 0, -6.6)
L.kit("flag_A_red", -8.2, 0, 7.2, ry=0.4)
flowerbed(5.5, 0, 2.5, 3, 2)
L.guide(0, 2.2, -7)
# Geriye bakan oyuncuya ipucu: arka kenardan aşağı inen pil sırası (gizli mağaraya)
L.battery_line((0, 0.4, 7.4), (0, -1.6, 9.6), 3)

# --- Gizli köşe 1: başlangıç adasının altındaki mağara (arka kenardan aşağı atla) ---
L.island(0, -4.5, 12, 7, 6, "grass2", skirt=False, under=True, depth=2.0)     # z[9,15], başlangıcın taşan katının altı
L.box(0, -0.6, 15.3, 7, 7.8, 0.6, "grass")                                      # arka duvar (düşmesin)
L.battery_ring((0, -4.5, 12.6), 1.8, 8)
L.ent("crate", -2.4, -4.5, 14, batteries=5)
L.ent("trampoline", 2.0, -4.5, 10.4, height=7.0)                                # geri dönüş
L.kenney("mushrooms", -2.6, -4.5, 10.2, 0.5, 2.6)
L.kenney("mushrooms", 1.6, -4.5, 14.2, 2.0, 2.2)

# =====================================================================================
# 1 · ÖĞRET: YAYLI TERASLAR (4 m basamaklar, Yay şart)
# =====================================================================================
L.top(-2, 4, -12, 12, 7, depth=8, theme="grass2")        # T1 x[-8,4]  z[-8.5,-15.5]
L.top(-5, 8, -19.5, 12, 7, depth=12, theme="grass")       # T2 x[-11,1] z[-16,-23]
L.battery_line((-1, 0.5, -7.6), (-1, 3.8, -7.6), 3)       # yukarı doğru pil sütunu
L.battery_line((-3.5, 4.5, -15.2), (-3.5, 7.8, -15.2), 3)
L.ent("checkpoint", -1.5, 8, -21.5, checkpoint_id="teras", ry=PI)
L.bush(-7, 4, -10, 0.8); L.bush(-9.5, 8, -17.5, 0.8)
L.tree(-9.5, 8, -21.8, 0.8, True)
L.kit("signage_arrow_stand_green", 2.5, 4, -14.5, ry=PI / 2)
flowerbed(-6.5, 8, -20.5, 2, 2, "flowers-tall")

# --- Gizli köşe 2: taş sütun (normal zıplama + kenara tutunma ile; Yay ile doğrudan) ---
L.island(6.5, 7.2, -12.5, 3, 3, "stone", skirt=False, under=False, depth=7.2)    # T1'in doğusu
L.battery_ring((6.5, 7.2, -12.5), 0.9, 5)
L.ent("crate", 6.5, 7.2, -13.6, batteries=3)
L.kit("flag_A_blue", 7.6, 7.2, -11.4)

# =====================================================================================
# 2 · BASAMAK TAŞLARI (ilk gerçek çukurlar, sağa kıvrılır)
# =====================================================================================
L.island(0, 8, -28, 4, 4, "grass2")                        # C1 z[-26,-30]
L.island(4.5, 8.5, -33.5, 3.5, 3.5, "grass")               # C2
L.island(2, 9, -39.5, 4, 4, "grass2")                      # C3 z[-37.5,-41.5]
L.island(-1, 9, -47, 7, 6, "grass")                        # C4 z[-44,-50]
L.battery_arc((-1, 8, -23.5), (0, 8, -26.5), 3, 2.5)
L.battery_arc((1, 8, -29.5), (4, 8.5, -32), 3, 2.5)
L.battery_arc((4, 8.5, -35.2), (2, 9, -38), 3, 2.5)
L.battery_arc((2, 9, -41.5), (0, 9, -44), 3, 2.0)
L.ent("enemy", -1, 9, -47, kind="vidabocek", patrol=2.0, speed=1.3, batteries=3)
L.ent("crate", 1.8, 9, -49, batteries=3)
L.tree(-3.8, 9, -49.2, 0.6)
L.kenney("flowers", 0.6, 8, -27.3, 0.3, 2.0)
L.kenney("flowers-tall", 4.9, 8.5, -32.6, 1.2, 1.8)

# =====================================================================================
# 3 · SINA: HAREKETLİ KÖPRÜ, PLATO VE ASANSÖR
# =====================================================================================
L.ent("platform", -1, 8.75, -52.5, kind="move", size=(4, 0.5, 4), offset=(0, 0, -8), duration=3.0)   # Platform_1
L.battery_line((-1, 9.6, -53), (-1, 9.6, -59), 3)
L.island(-1, 9, -67, 12, 9, "grass")                       # D x[-7,5] z[-62.5,-71.5]
L.ent("enemy", 2.5, 9, -66, kind="zipzip", batteries=2)
L.ent("enemy", -3, 9, -69, kind="vidabocek", patrol=2.5, speed=1.4, batteries=3)
L.ent("crate", 4, 9, -63.5, batteries=3)
L.ent("crate", -6, 9, -70.5, batteries=2)
L.battery_ring((-1, 9, -66.5), 2.0, 6)
L.tree(-6, 9, -63.5, 0.7, True)
L.kit("cone_yellow", 4.4, 9, -70.8); L.kit("cone_yellow", 3.8, 9, -71.1)
L.ent("platform", -1, 8.75, -73.6, kind="move", size=(3, 0.5, 3), offset=(0, 6, 0), duration=3.0, color=(0.95, 0.75, 0.3, 1))  # Platform_2 asansör
L.battery_line((-1, 10.5, -73.6), (-1, 14.5, -73.6), 3)
L.guide(-1, 11.5, -66)

# =====================================================================================
# 4 · ÇİÇEK TEPESİ (dinlenme, manzara, kontrol noktası)
# =====================================================================================
L.island(-1, 15, -81, 14, 10, "grass")                     # E x[-8,6] z[-76,-86]
L.ent("checkpoint", 3, 15, -78, checkpoint_id="tepe", ry=PI)
L.ent("copy", -5, 15, -78.5, ability="yay")
L.battery_ring((-1, 15, -81.5), 3.0, 10)
L.tree(-7, 15, -84.6, 1.1, True); L.tree(5, 15, -85, 0.9)
flowerbed(-4.5, 15, -83, 3, 2); flowerbed(2.5, 15, -82.5, 2, 2, "flowers-tall")
L.kit("arch_wide_green", -1, 15, -85.6)
L.label(-1, 19.5, -86, "Çiçek Tepesi", 64)

# =====================================================================================
# 5 · ŞAŞIRT: TRAMBOLİNLER PLATFORMLA GİDİP GELİR
# =====================================================================================
pa = L.ent("platform", -5, 14.75, -90, kind="move", size=(4, 0.5, 4), offset=(8, 0, 0), duration=2.5, color=(0.45, 0.8, 1.0, 1))   # Platform_3
L.ent("trampoline", 0, 0.25, 0, parent="Entities/" + pa, height=6.0)
pb = L.ent("platform", 3, 17.75, -97.5, kind="move", size=(4, 0.5, 4), offset=(-8, 0, 0), duration=2.5, color=(0.45, 0.8, 1.0, 1))
L.ent("trampoline", 0, 0.25, 0, parent="Entities/" + pb, height=6.0)
pc = L.ent("platform", -5, 20.75, -105, kind="move", size=(4, 0.5, 4), offset=(8, 0, 0), duration=2.5, color=(0.45, 0.8, 1.0, 1))
L.ent("trampoline", 0, 0.25, 0, parent="Entities/" + pc, height=6.0)
L.battery_arc((-1, 15, -87), (-1, 18, -96), 6, 5.5)
L.battery_arc((-1, 18, -98), (-1, 21, -104), 5, 5.5)
L.guide(-1, 18, -90)

# --- Gizli köşe 3: gökteki Altın Vida adası (B platformu doğuya gelince trambolinden) ---
L.island(10.5, 22.5, -97.5, 3, 3, "yellow", skirt=False, under=True, depth=1.5)
L.ent("screw", 10.5, 22.7, -97.5)
L.kit("flag_C_yellow", 11.6, 22.5, -98.6, ry=PI)
L.kit("star_yellow", 10.5, 25.5, -97.5, s=1.4)

# =====================================================================================
# 6 · EZME BAHÇESİ (Yay ile düşman ezme)
# =====================================================================================
L.island(-1, 21, -115, 14, 12, "grass2")                   # G x[-8,6] z[-109,-121]
L.ent("checkpoint", 4, 21, -110.5, checkpoint_id="bahce", ry=PI)
L.ent("copy", -6, 21, -110.5, ability="yay")
for i, (x, z) in enumerate(((-4, -114), (-1, -116.5), (2, -114), (-2.5, -119), (1.5, -119))):
    L.ent("enemy", x, 21, z, kind="vidabocek", patrol=1.6, speed=1.0 + 0.15 * i, batteries=2)
L.ent("enemy", 4.5, 21, -117, kind="zipzip", batteries=3)
for x, z in ((-7, -120.3), (5.3, -120.3), (-7, -113)):
    L.ent("crate", x, 21, z, batteries=3)
L.battery_ring((-1, 21, -116), 4.0, 12)
L.tree(-7, 21, -109.8, 0.7); L.kit("pipe_straight_A_green", 5.6, 21, -113.5)
L.kit("signage_arrow_stand_red", 3.5, 21, -120.6, ry=PI / 2)

# =====================================================================================
# 7 · USTALIK: DÖNEN KULE
# =====================================================================================
s1 = L.ent("platform", -1, 20.75, -126, kind="spin", size=(8, 0.5, 8), duration=10.0, color=(0.55, 0.85, 0.35, 1))
L.ent("enemy", 1, 21.1, -126, kind="vidabocek", patrol=1.5, speed=1.0, batteries=2)
s2 = L.ent("platform", 4, 25.25, -133, kind="spin", size=(6, 0.5, 6), duration=-8.0, color=(0.98, 0.84, 0.32, 1))
L.ent("trampoline", 1.6, 0.25, 1.6, parent="Entities/" + s2, height=5.5)
s3 = L.ent("platform", -2, 29.75, -139, kind="spin", size=(6, 0.5, 6), duration=7.0, color=(0.55, 0.85, 0.35, 1))
L.ent("enemy", -2, 30.1, -139, kind="vidabocek", patrol=1.2, speed=1.0, batteries=2)
L.battery_line((-1, 21, -122.5), (-1, 21, -128), 3)
L.battery_arc((0, 21.5, -128), (4, 25.5, -132), 4, 3.0)
L.battery_arc((3, 25.5, -134), (-2, 30, -138), 4, 3.0)
L.guide(1.5, 27.5, -129)

# =====================================================================================
# 8 · BİTİŞ: DEV YAY ile kulenin tepesine (başlangıçtan görünen yer işareti)
# =====================================================================================
L.island(-1, 30, -147, 12, 8, "grass")                     # X x[-7,5] z[-143,-151]
L.ent("trampoline", -1, 30, -146.5, height=11.0)           # Dev Yay
L.ent("hint", -1, 30, -146.5, hint="hold_jump", size=(4, 3, 4))
L.battery_line((-1, 31.5, -146.5), (-1, 39.5, -149.5), 6)
L.tree(-6, 30, -150.3, 0.8, True); L.tree(4, 30, -150.3, 0.7)
L.top(-1, 40, -153, 7, 6, depth=10, theme="stone")         # Bitiş kulesi x[-4.5,2.5] z[-150,-156]
L.ent("exit", -1, 40, -154)
L.kit("signage_finish_wide", -1, 40, -151.4)
L.kit("flag_A_red", -4, 40, -155.6); L.kit("flag_A_yellow", 2, 40, -155.6)
L.kit("star_yellow", -1, 45.5, -154, s=2.2)
L.guide(-1, 34, -146)

# =====================================================================================
# Manzara: uzak adalar, ağaçlar, bulutlar (oynanış yok)
# =====================================================================================
for (x, y, z, w, d) in ((-38, -2, -30, 14, 12), (42, 4, -60, 16, 12), (-46, 10, -110, 18, 14),
                        (40, 18, -140, 14, 14), (-30, -6, 30, 12, 10), (34, -4, 18, 10, 10)):
    L.island(x, y, z, w, d, "grass2", skirt=True)
    for k in range(3):
        L.deco("k_tree" if k % 2 == 0 else "k_pine", x - w / 3 + k * w / 3, y, z + (k - 1) * 2.5, 1.0 + 0.3 * k)
L.clouds(30, xr=(-110, 110), zr=(-230, 70), avoid=(-22, 22, -165, 25), low=(-8, -3), high=(10, 50))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("magara", 0, -4.5, 12, 7, 6)
L.secret("sutun", 6.5, 7.2, -12.5, 3, 3)
L.secret("gok", 10.5, 22.5, -97.5, 3, 3)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.vista(0, 0, 2.5, (-1, 44, -154), "Dev Yay Kulesi", size=(14, 4, 2))
# Gök adası: Çiçek Tepesi'ndeki toptan fırla, pilleri topla, ikinci topla geri dön
L.cannon(-6.8, 15, -80.3, (-25.5, 26, -85.5))
L.top(-24, 26, -84, 7, 7, depth=1.4, theme="grass")
L.battery_ring((-24, 26, -84), 2.2, 8)
L.ent("crate", -26.3, 26, -82.2, batteries=5)
L.battery_arc((-9, 18, -81), (-22, 28, -85), 6, 5.0)
L.cannon(-21.8, 26, -82.2, (-1, 15, -80.5))
# Hikâye anı (2026-11-22; docs/features/hikaye/design.md): Statik yolun ilerisinde belirir ve kaçar
L.setpiece("statik", 3, 21, -111.5, (-1, 30, -128), size=(12, 5, 3))
L.write()
