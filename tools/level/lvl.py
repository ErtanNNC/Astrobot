# Seviye üretici kütüphane: Python'da yazılan yerleşimi Godot sahnesine (.tscn) çevirir.
# Her alanın betiği (tools/level/ch1_*.py) bunu kullanır.
# DİKKAT: Sahneyi Godot editöründe elle düzenlediysen betiği tekrar çalıştırma; değişikliğin silinir.
import math, random, os

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", ".."))

THEMES = {
    "grass": ((0.55,0.82,0.25),(0.47,0.74,0.22),(0.95,0.70,0.45),(0.87,0.58,0.36)),
    "grass2": ((0.62,0.85,0.30),(0.52,0.77,0.25),(0.98,0.80,0.50),(0.90,0.68,0.40)),
    "sand": ((0.97,0.86,0.58),(0.93,0.80,0.52),(0.95,0.70,0.45),(0.87,0.58,0.36)),
    "canyon": ((0.95,0.62,0.38),(0.90,0.55,0.33),(0.86,0.45,0.28),(0.76,0.38,0.24)),
    "stone": ((0.78,0.80,0.84),(0.72,0.74,0.79),(0.62,0.64,0.70),(0.55,0.57,0.63)),
    "quarry": ((0.80,0.74,0.64),(0.74,0.68,0.58),(0.66,0.58,0.48),(0.58,0.50,0.42)),
    "wood": ((0.80,0.55,0.32),(0.74,0.50,0.29),(0.66,0.43,0.25),(0.58,0.37,0.21)),
    "floor": ((0.78,0.62,0.45),(0.74,0.58,0.42),(0.55,0.45,0.38),(0.50,0.40,0.34)),
    "factory": ((0.55,0.58,0.64),(0.50,0.53,0.60),(0.42,0.45,0.52),(0.36,0.39,0.46)),
    "purple": ((0.70,0.55,0.90),(0.64,0.50,0.85),(0.56,0.42,0.75),(0.50,0.37,0.68)),
    "yellow": ((0.98,0.84,0.32),(0.95,0.78,0.28),(0.95,0.70,0.45),(0.87,0.58,0.36)),
    "blue": ((0.45,0.70,1.00),(0.40,0.64,0.95),(0.35,0.55,0.85),(0.30,0.48,0.78)),
    "snow": ((0.95,0.97,1.00),(0.88,0.92,0.98),(0.62,0.70,0.82),(0.54,0.62,0.75)),
    "ice": ((0.72,0.90,1.00),(0.65,0.85,0.98),(0.50,0.72,0.90),(0.44,0.64,0.84)),
    "red": ((0.95,0.45,0.40),(0.90,0.40,0.36),(0.80,0.35,0.30),(0.72,0.30,0.26)),
    "cloud": ((0.98,0.97,1.00),(0.92,0.90,0.98),(0.82,0.78,0.95),(0.74,0.70,0.90)),
}

SKIES = {
    "day":     dict(top=(0.25,0.55,0.95), hor=(0.72,0.88,1.0), sun=(1,0.96,0.88), sun_e=1.25, amb=1.1, fog=(0.72,0.86,1.0), fog_d=0.0035, sun_rx=-50, sun_ry=30),
    "sunset":  dict(top=(0.35,0.45,0.85), hor=(1.0,0.75,0.55), sun=(1,0.82,0.62), sun_e=1.3, amb=1.0, fog=(1.0,0.8,0.65), fog_d=0.004, sun_rx=-28, sun_ry=60),
    "indoor":  dict(top=(0.30,0.35,0.50), hor=(0.55,0.55,0.65), sun=(1,0.9,0.75), sun_e=1.0, amb=1.3, fog=(0.45,0.45,0.55), fog_d=0.006, sun_rx=-60, sun_ry=20),
    "factory": dict(top=(0.30,0.40,0.60), hor=(0.65,0.70,0.80), sun=(0.95,0.95,1.0), sun_e=1.15, amb=1.15, fog=(0.6,0.65,0.75), fog_d=0.005, sun_rx=-55, sun_ry=-40),
    "quarry":  dict(top=(0.35,0.60,0.95), hor=(0.95,0.88,0.75), sun=(1,0.93,0.8), sun_e=1.3, amb=1.05, fog=(0.95,0.88,0.78), fog_d=0.004, sun_rx=-45, sun_ry=10),
    "night":   dict(top=(0.04,0.06,0.16), hor=(0.15,0.18,0.32), sun=(0.6,0.7,1.0), sun_e=0.35, amb=0.5, fog=(0.1,0.12,0.25), fog_d=0.01, sun_rx=-40, sun_ry=30),
    "storm":   dict(top=(0.12,0.10,0.22), hor=(0.30,0.25,0.42), sun=(0.8,0.7,1.0), sun_e=0.6, amb=0.8, fog=(0.25,0.22,0.38), fog_d=0.006, sun_rx=-50, sun_ry=30),
}

DECOR = {
    # ad: (dosya, temel ölçek, y düzeltmesi oranı)
    "tree": ("Tree", 0.55, 0), "tree_fruit": ("Tree_Fruit", 0.55, 0), "bush": ("Bush", 0.4, 0),
    "bush_fruit": ("Bush_Fruit", 0.4, 0), "grass": ("Grass_1", 1.0, -0.92), "grass2": ("Grass_2", 1.0, -0.92),
    "grass3": ("Grass_3", 1.0, -0.92), "rock": ("Rock_1", 0.7, 0), "rock2": ("Rock_2", 0.7, 0),
    "cloud": ("Cloud_1", 2.4, 0), "cloud2": ("Cloud_2", 2.4, 0), "cloud3": ("Cloud_3", 2.4, 0),
    "flag": ("Goal_Flag", 0.9, 0), "arrow": ("Arrow", 0.8, 0), "arrow_up": ("Arrow_Up", 0.6, 0),
    "arrow_side": ("Arrow_Side", 0.6, 0), "plant": ("Plant_Large", 0.8, 0), "plant_small": ("Plant_Small", 0.8, 0),
    "fence": ("Fence_Middle", 0.8, 0), "fence_corner": ("Fence_Corner", 0.8, 0), "pipe": ("Pipe_Straight", 0.5, 0.5),
    "pipe90": ("Pipe_90", 0.5, 0.5), "pipe_end": ("Pipe_End", 0.5, 0.5), "tower": ("Tower", 0.5, 0), "chest": ("Chest", 0.5, 0),
    "door": ("Door", 0.6, 0), "lever": ("Lever", 0.8, 0), "cannon": ("Cannon", 0.5, 0.27), "bomb": ("Bomb", 0.5, 0.29),
    "gem": ("Gem_Blue", 0.4, 0.42), "gem_pink": ("Gem_Pink", 0.4, 0.4), "star": ("Star", 0.5, 0.32), "key": ("Key", 0.6, 0.3),
    "rockplat": ("RockPlatforms_1", 0.7, 0), "rockplat2": ("RockPlatforms_2", 0.7, 0), "rocktall": ("RockPlatform_Tall", 0.7, 0),
    "bricks": ("Cube_Bricks", 0.5, 0.5), "qblock": ("Cube_Question", 0.5, 0.5), "bridge": ("Bridge_Small", 0.6, 0.17),
    "stairs": ("Stairs", 0.6, 0.6), "spikes_deco": ("Spikes", 0.4, 0),
}

ENTITIES = {
    "copy": ("Area3D", "res://scripts/abilities/copy_source.gd"),
    "battery": ("Area3D", "res://scripts/entities/battery.gd"),
    "screw": ("Area3D", "res://scripts/entities/golden_screw.gd"),
    "checkpoint": ("Area3D", "res://scripts/entities/checkpoint.gd"),
    "crate": ("StaticBody3D", "res://scripts/entities/crate.gd"),
    "enemy": ("CharacterBody3D", "res://scripts/entities/enemy.gd"),
    "hazard": ("Area3D", "res://scripts/entities/hazard.gd"),
    "wind": ("Area3D", "res://scripts/entities/wind_zone.gd"),
    "metal": ("StaticBody3D", "res://scripts/entities/metal_block.gd"),
    "cracked": ("StaticBody3D", "res://scripts/entities/cracked_floor.gd"),
    "button": ("Area3D", "res://scripts/entities/heavy_button.gd"),
    "gate": ("AnimatableBody3D", "res://scripts/entities/gate.gd"),
    "water": ("Area3D", "res://scripts/entities/water_zone.gd"),
    "exit": ("Area3D", "res://scripts/entities/area_exit.gd"),
    "platform": ("AnimatableBody3D", "res://scripts/entities/platforms.gd"),
    "hint": ("Area3D", "res://scripts/entities/hint_zone.gd"),
    "trampoline": ("Area3D", "res://scripts/entities/trampoline.gd"),
    "camzone": ("Area3D", "res://scripts/level/camera_zone.gd"),
    "trigger": ("Area3D", "res://scripts/entities/trigger.gd"),
    "prop": ("Node3D", "res://scripts/entities/prop.gd"),
    "menu": ("Area3D", "res://scripts/ui/menu_object.gd"),
    "boss": ("Node3D", "res://scripts/boss/crane_boss.gd"),
    "giant": ("Node3D", "res://scripts/boss/snow_giant_boss.gd"),
    "captain": ("Node3D", "res://scripts/boss/captain_boss.gd"),
    "statik": ("Node3D", "res://scripts/boss/static_boss.gd"),
}


def fmt(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return "%.6g" % v
    if isinstance(v, str):
        if v.startswith("@raw:"):
            return v[5:]
        return '"%s"' % v
    if isinstance(v, tuple) and len(v) == 3:
        return "Vector3(%s, %s, %s)" % tuple(fmt(c) for c in v)
    if isinstance(v, tuple) and len(v) == 2:
        return "Vector2(%s, %s)" % tuple(fmt(c) for c in v)
    if isinstance(v, tuple) and len(v) == 4:
        return "Color(%s, %s, %s, %s)" % tuple(fmt(c) for c in v)
    if isinstance(v, list):
        return 'Array[NodePath]([%s])' % ", ".join('NodePath("%s")' % p for p in v)
    raise ValueError(v)


def tf(x, y, z, rx=0.0, ry=0.0, s=1.0, rz=0.0):
    cx, sx = math.cos(rx), math.sin(rx)
    cy, sy = math.cos(ry), math.sin(ry)
    cz, sz = math.cos(rz), math.sin(rz)
    def rot(v):
        # Rz, sonra Rx, sonra Ry
        v = (cz*v[0]-sz*v[1], sz*v[0]+cz*v[1], v[2])
        v = (v[0], cx*v[1]-sx*v[2], sx*v[1]+cx*v[2])
        return (cy*v[0]+sy*v[2], v[1], -sy*v[0]+cy*v[2])
    X, Y, Z = [tuple(c*s if isinstance(s, (int, float)) else c for c in rot(v)) for v in ((1,0,0),(0,1,0),(0,0,1))]
    if isinstance(s, tuple):
        X = tuple(c*s[0] for c in X); Y = tuple(c*s[1] for c in Y); Z = tuple(c*s[2] for c in Z)
    f = lambda v: ", ".join("%.6g" % c for c in v)
    return "Transform3D(%s, %s, %s, %s)" % (f(X), f(Y), f(Z), f((x, y, z)))


class Level:
    def __init__(self, area_id, title, out, sky="day", music="res://assets/audio/opengameart/happy_clappy_loop.mp3",
                 kill_height=-12.0, safe=False, water=-8.0, seed=1, start_ability="", root_script="res://scripts/level/area.gd", extra_props=None, rig=True):
        random.seed(seed)
        self.area_id, self.title, self.out = area_id, title, out
        self.sky, self.music, self.kill, self.safe, self.water = sky, music, kill_height, safe, water
        self.start_ability = start_ability
        self.root_script = root_script
        self.extra_props = extra_props or {}
        self.rig = rig
        self.nodes = []
        self.ext = {}
        self.used_themes = set()
        self.counters = {}
        self.groups = ["Level", "Entities", "Batteries", "Decor", "Clouds", "Guide", "Labels"]

    def _ext(self, kind, path):
        key = path
        if key not in self.ext:
            self.ext[key] = (kind, "e%d" % len(self.ext))
        return self.ext[key][1]

    def _name(self, base):
        n = self.counters.get(base, 0) + 1
        self.counters[base] = n
        return "%s_%d" % (base, n)

    # ---- Zemin kutuları (ölçülü, çarpışmalı) ----
    def box(self, x, y, z, sx, sy, sz, theme="grass", rx=0.0, ry=0.0, name=None, parent="Level"):
        self.used_themes.add(theme)
        name = name or self._name("Kutu")
        self.nodes.append('[node name="%s" type="CSGBox3D" parent="%s"]\ntransform = %s\nuse_collision = true\nsize = Vector3(%s, %s, %s)\nmaterial = SubResource("m_%s")\n'
                          % (name, parent, tf(x, y, z, rx, ry), fmt(sx), fmt(sy), fmt(sz), theme))
        return name

    def top(self, cx, top, cz, sx, sz, depth=3.0, theme="grass", name=None, ry=0.0):
        """Üst yüzeyi 'top' yüksekliğinde olan kutu (çoğu zemin böyle)."""
        return self.box(cx, top - depth / 2, cz, sx, depth, sz, theme, ry=ry, name=name)

    def ramp(self, cx, cz, length, width, rise, theme="grass2", ry=0.0, base=0.0):
        """base yüksekliğinden başlayıp yerel -Z yönünde 'rise' kadar yükselen rampa."""
        a = math.atan2(rise, length)
        L = math.hypot(length, rise)
        return self.box(cx, base + rise / 2 - 0.2 * math.cos(a), cz, width, 0.4, L, theme, rx=a, ry=ry)

    # ---- Varlıklar ----
    def ent(self, etype, x, y, z, ry=0.0, name=None, parent="Entities", groups=None, meta=None, **props):
        typ, path = ENTITIES[etype]
        e = self._ext("Script", path)
        name = name or self._name(etype.capitalize())
        g = (' groups=[%s]' % ", ".join('"%s"' % x for x in groups)) if groups else ""
        lines = ['[node name="%s" type="%s" parent="%s"%s]' % (name, typ, parent, g), "transform = %s" % tf(x, y, z, 0, ry), 'script = ExtResource("%s")' % e]
        for k, v in props.items():
            lines.append("%s = %s" % (k, fmt(v)))
        for k, v in (meta or {}).items():
            lines.append("metadata/%s = %s" % (k, fmt(v)))
        self.nodes.append("\n".join(lines) + "\n")
        return name

    def battery(self, x, y, z):
        return self.ent("battery", x, y + 0.8, z, parent="Batteries", name=self._name("Pil"))

    def battery_line(self, a, b, n):
        for i in range(n):
            t = i / max(n - 1, 1)
            self.battery(a[0] + (b[0]-a[0])*t, a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t)

    def battery_arc(self, a, b, n, h):
        for i in range(n):
            t = i / max(n - 1, 1)
            self.battery(a[0] + (b[0]-a[0])*t, a[1] + (b[1]-a[1])*t + math.sin(t*math.pi)*h, a[2] + (b[2]-a[2])*t)

    def battery_ring(self, c, r, n, y=0.0):
        for i in range(n):
            a = math.tau * i / n
            self.battery(c[0] + math.cos(a)*r, c[1] + y, c[2] + math.sin(a)*r)

    def guide(self, x, y, z):
        self.nodes.append('[node name="%s" type="Marker3D" parent="Guide" groups=["piril_point"]]\ntransform = %s\n' % (self._name("Pirilnokta"), tf(x, y, z)))

    def label(self, x, y, z, text, size=56):
        self.nodes.append('[node name="%s" type="Label3D" parent="Labels"]\ntransform = %s\nbillboard = 1\nfont_size = %d\noutline_size = 16\noutline_modulate = Color(0.15, 0.2, 0.35, 1)\ntext = "%s"\n' % (self._name("Yazi"), tf(x, y, z), size, text))

    # ---- Süsler ----
    def deco(self, kind, x, y, z, s=1.0, ry=None, parent="Decor", collide=None):
        file, base, yoff = DECOR[kind]
        folder = "platformer"
        e = self._ext("PackedScene", "res://assets/models/quaternius/%s/%s.gltf" % (folder, file))
        if ry is None:
            ry = random.uniform(0, math.tau)
        sc = base * s
        name = self._name(file)
        if collide:
            self.nodes.append('[node name="%s" type="StaticBody3D" parent="%s"]\ntransform = %s\n' % (name, parent, tf(x, y, z, 0, ry)))
            self.nodes.append('[node name="Model" parent="%s/%s" instance=ExtResource("%s")]\ntransform = %s\n' % (parent, name, e, tf(0, yoff*sc, 0, 0, 0, sc)))
            shape, off = collide
            self.nodes.append('[node name="Shape" type="CollisionShape3D" parent="%s/%s"]\ntransform = %s\nshape = SubResource("%s")\n' % (parent, name, tf(0, off, 0), shape))
        else:
            self.nodes.append('[node name="%s" parent="%s" instance=ExtResource("%s")]\ntransform = %s\n' % (name, parent, e, tf(x, y + yoff*sc, z, 0, ry, sc)))

    def tree(self, x, y, z, s=1.0, fruit=None):
        self.deco("tree_fruit" if (fruit if fruit is not None else random.random() < 0.4) else "tree", x, y, z, s, collide=("trunk", 1.2))

    def rock(self, x, y, z, s=1.0):
        self.deco(random.choice(["rock", "rock2"]), x, y, z, s, collide=("rockshape", 0.35*s))

    def bush(self, x, y, z, s=1.0):
        self.deco(random.choice(["bush", "bush_fruit"]), x, y, z, s)

    def grass_patch(self, x0, x1, z0, z1, y, n, avoid=()):
        k = 0; tries = 0
        while k < n and tries < 400:
            tries += 1
            x = random.uniform(x0, x1); z = random.uniform(z0, z1)
            if any(a[0] <= x <= a[1] and a[2] <= z <= a[3] for a in avoid):
                continue
            self.deco(random.choice(["grass", "grass2", "grass3"]), x, y, z, random.uniform(0.9, 1.3))
            k += 1

    def clouds(self, n=20, xr=(-80, 80), zr=(-160, 60), avoid=(-30, 30, -140, 30), low=(-6, -3), high=(10, 22)):
        k = 0
        while k < n:
            x = random.uniform(*xr); z = random.uniform(*zr)
            if avoid[0] < x < avoid[1] and avoid[2] < z < avoid[3]:
                continue
            y = random.choice([random.uniform(*low), random.uniform(*high)])
            self.deco(random.choice(["cloud", "cloud2", "cloud3"]), x, y, z, random.uniform(0.7, 1.3), parent="Clouds")
            k += 1

    # ---- Yazma ----
    def write(self):
        S = SKIES[self.sky]
        ext_lines = ['[ext_resource type="Script" path="%s" id="area"]' % self.root_script,
                     '[ext_resource type="PackedScene" path="res://scenes/common/game_rig.tscn" id="rig"]',
                     '[ext_resource type="Shader" path="res://assets/shaders/toon_terrain.gdshader" id="sh"]',
                     '[ext_resource type="Shader" path="res://assets/shaders/water.gdshader" id="water"]']
        if self.music:
            ext_lines.append('[ext_resource type="AudioStream" path="%s" id="music"]' % self.music)
        for path, (kind, eid) in self.ext.items():
            ext_lines.append('[ext_resource type="%s" path="%s" id="%s"]' % (kind, path, eid))
        c3 = lambda c: "Color(%.3f, %.3f, %.3f, 1)" % c
        subs = []
        for k in sorted(self.used_themes):
            t1, t2, a, b = THEMES[k]
            subs.append('[sub_resource type="ShaderMaterial" id="m_%s"]\nrender_priority = 0\nshader = ExtResource("sh")\nshader_parameter/top_color = %s\nshader_parameter/top_color2 = %s\nshader_parameter/side_a = %s\nshader_parameter/side_b = %s\n' % (k, c3(t1), c3(t2), c3(a), c3(b)))
        subs.append('''[sub_resource type="CylinderShape3D" id="trunk"]
height = 2.4
radius = 0.35

[sub_resource type="SphereShape3D" id="rockshape"]
radius = 0.45

[sub_resource type="ShaderMaterial" id="water_mat"]
render_priority = 0
shader = ExtResource("water")

[sub_resource type="PlaneMesh" id="water_mesh"]
material = SubResource("water_mat")
size = Vector2(500, 500)
subdivide_width = 60
subdivide_depth = 60

[sub_resource type="ProceduralSkyMaterial" id="sky_mat"]
sky_top_color = %s
sky_horizon_color = %s
sky_curve = 0.12
ground_bottom_color = Color(0.2, 0.45, 0.75, 1)
ground_horizon_color = %s
sun_angle_max = 20.0

[sub_resource type="Sky" id="sky"]
sky_material = SubResource("sky_mat")

[sub_resource type="Environment" id="env"]
background_mode = 2
sky = SubResource("sky")
ambient_light_source = 3
ambient_light_color = Color(1, 1, 1, 1)
ambient_light_sky_contribution = 0.6
ambient_light_energy = %.3f
tonemap_mode = 2
tonemap_white = 6.0
glow_enabled = true
glow_intensity = 0.4
glow_bloom = 0.05
fog_enabled = true
fog_light_color = %s
fog_density = %.4f
fog_sky_affect = 0.0
adjustment_enabled = true
adjustment_saturation = 1.12
''' % (c3(S["top"]), c3(S["hor"]), c3(S["hor"]), S["amb"], c3(S["fog"]), S["fog_d"]))
        props = ['area_id = "%s"' % self.area_id, 'title = "%s"' % self.title, "kill_height = %s" % fmt(self.kill)]
        if self.safe:
            props.append("safe = true")
        if self.start_ability:
            props.append('start_ability = "%s"' % self.start_ability)
        if self.music:
            props.append('music = ExtResource("music")')
        for k, v in self.extra_props.items():
            props.append("%s = %s" % (k, fmt(v)))
        root = ['[node name="%s" type="Node3D"]\nscript = ExtResource("area")\n%s\n' % (self.area_id, "\n".join(props)),
                '[node name="WorldEnvironment" type="WorldEnvironment" parent="."]\nenvironment = SubResource("env")\n',
                '[node name="Sun" type="DirectionalLight3D" parent="."]\ntransform = %s\nlight_color = %s\nlight_energy = %.2f\nshadow_enabled = true\nshadow_blur = 1.5\ndirectional_shadow_mode = 0\ndirectional_shadow_max_distance = 45.0\n'
                % (tf(0, 10, 0, math.radians(S["sun_rx"]), math.radians(S["sun_ry"])), c3(S["sun"]), S["sun_e"])]
        if self.water is not None:
            root.append('[node name="Sea" type="MeshInstance3D" parent="."]\ntransform = %s\nmesh = SubResource("water_mesh")\ncast_shadow = 0\n' % tf(0, self.water, -40))
        if self.rig:
            root.append('[node name="GameRig" parent="." instance=ExtResource("rig")]\n')
        for g in self.groups:
            root.append('[node name="%s" type="Node3D" parent="."]\n' % g)
        txt = "[gd_scene format=3]\n\n" + "\n".join(ext_lines) + "\n\n" + "\n".join(subs) + "\n" + "\n".join(root) + "\n" + "\n".join(self.nodes)
        path = os.path.join(ROOT, self.out)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write(txt)
        print("yazıldı:", self.out, "düğüm:", len(self.nodes))

    def start(self, x, y, z, ry=0.0):
        self.nodes.append('[node name="Start" type="Marker3D" parent="."]\ntransform = %s\n' % tf(x, y, z, 0, ry))
