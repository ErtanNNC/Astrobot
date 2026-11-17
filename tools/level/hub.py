# Giriş ekranı + Atölye (oynanabilir ana menü). Tasarım: docs/features/ana-menu/design.md
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("hub", "", "scenes/ui/hub.tscn", sky="indoor", music=None, water=None, safe=True,
          root_script="res://scripts/ui/hub.gd", seed=5)


def wall(x0, x1, z0, z1, top, bottom=0.0, theme="wood"):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


L.top(0, 0, -1, 19, 17, depth=1.0, theme="floor")      # x[-9.5,9.5] z[7.5,-9.5]
wall(-9.5, -9.0, 7.5, -9.5, 4.0); wall(9.0, 9.5, 7.5, -9.5, 4.0); wall(-9.5, 9.5, 7.5, 8.0, 4.0)
# Kuzey duvarı: ortada büyük kapı, sağda pencere (dışarıda yağmur)
wall(-9.5, -2.0, -9.0, -9.5, 4.0); wall(2.0, 4.0, -9.0, -9.5, 4.0); wall(7.5, 9.5, -9.0, -9.5, 4.0)
wall(-2.0, 2.0, -9.0, -9.5, 4.0, 3.4)
wall(4.0, 7.5, -9.0, -9.5, 1.2); wall(4.0, 7.5, -9.0, -9.5, 4.0, 3.2)
L.ent("prop", 5.75, 8, -16, kind="rain", size=0.8)

L.start(0, 0.35, 1.5, ry=0.0)
L.ent("prop", 0, 0, 1.5, kind="station")
L.ent("menu", 0, 0, -8.5, kind="door", action="play")
for i, z in enumerate((-4.5, -1.0, 2.5)):
    L.ent("menu", 7.4, 0, z, ry=-math.pi / 2, kind="capsule", action="slot", arg=str(i))
L.ent("menu", -7.6, 0, -3.5, ry=math.pi / 2, kind="tv", action="settings")
L.ent("menu", -7.2, 0, 4.2, ry=math.pi / 2, kind="showcase", action="collection")
L.ent("menu", 4.5, 0, 6.2, ry=math.pi, kind="toybox", action="toybox")
L.ent("menu", -4.0, 0, -8.6, kind="switch", action="quit", name="Salter")
for i, a in enumerate(("yay", "balon", "miknatis", "kaya")):
    L.ent("copy", 1.8 + i * 1.6, 0, 4.6, ability=a, groups=["toy"])

L.ent("prop", -8.9, 2.4, 0.5, kind="gear", size=1.1, spin=0.5, ry=math.pi / 2)
L.ent("prop", -8.9, 1.5, -6.5, kind="gear", size=0.7, spin=-0.8, ry=math.pi / 2)
L.ent("prop", 8.9, 3.0, 5.5, kind="gear", size=0.8, spin=0.7, ry=math.pi / 2)
for p in ((0, 3.2, -2), (-5, 3.2, 3), (5, 3.2, 3)):
    L.ent("prop", *p, kind="lamp")
L.ent("crate", -8.0, 0, -8.0, batteries=0)
L.ent("crate", -8.0, 1.0, -8.0, batteries=0)
L.ent("crate", -6.9, 0, -8.0, batteries=0)
L.deco("chest", 8.0, 0, 6.5, 1.0, ry=-2.4)
L.deco("pipe", -9.0, 3.3, -3, 0.6, ry=0)
L.ent("prop", -2.5, 2.4, 7.4, kind="screen", color=(0.5, 0.9, 0.6, 1), ry=math.pi)
L.write()
