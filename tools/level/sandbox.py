# Yetenek deneme alanı (geliştirici testi için): her yetenekten bir kaynak, su havuzu, düşman.
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level
L = Level("sandbox", "Deneme Alanı", "scenes/levels/sandbox.tscn", sky="day", water=-8, seed=2)
L.top(0, 0, 0, 30, 30, depth=3, theme="grass")
L.start(0, 0.1, 10, ry=math.pi)
for i, a in enumerate(("yay", "balon", "miknatis", "kaya", "pervane", "buz")):
    L.ent("copy", -10 + i * 4, 0, 12, ability=a)
L.top(0, -2, -25, 14, 20, depth=1, theme="sand")             # havuz tabanı
L.ent("water", 0, 0, -25, size=(14, 2, 20))
L.box(-7.5, -1, -25, 1, 2, 20, "stone"); L.box(7.5, -1, -25, 1, 2, 20, "stone")
L.top(0, 0, -45, 20, 20, depth=3, theme="grass")
L.ent("enemy", 6, 0, 0, kind="vidabocek", patrol=2)
L.top(-10, 6, -5, 4, 4, depth=1, theme="yellow")             # yüksek platform (6 m)
L.write()
