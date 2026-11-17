# M1 test alanı sahnesini (scenes/levels/test_area.tscn) üretir.
# DİKKAT: Sahneyi Godot editöründe elle düzenlediysen bunu çalıştırma; değişikliklerin silinir.
# Kullanım: python3 tools/level/gen_test_area.py
import math, random, os
random.seed(7)
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "scenes", "levels", "test_area.tscn")

# Zemin temaları: (üst1, üst2, yan_a, yan_b)
themes = {
 "grass": ((0.55,0.82,0.25),(0.47,0.74,0.22),(0.95,0.70,0.45),(0.87,0.58,0.36)),
 "grass2": ((0.62,0.85,0.30),(0.52,0.77,0.25),(0.98,0.80,0.50),(0.90,0.68,0.40)),
 "sand": ((0.97,0.86,0.58),(0.93,0.80,0.52),(0.95,0.70,0.45),(0.87,0.58,0.36)),
 "stone": ((0.78,0.80,0.84),(0.72,0.74,0.79),(0.62,0.64,0.70),(0.55,0.57,0.63)),
 "wood": ((0.80,0.55,0.32),(0.74,0.50,0.29),(0.66,0.43,0.25),(0.58,0.37,0.21)),
 "purple": ((0.70,0.55,0.90),(0.64,0.50,0.85),(0.56,0.42,0.75),(0.50,0.37,0.68)),
 "yellow": ((0.98,0.84,0.32),(0.95,0.78,0.28),(0.95,0.70,0.45),(0.87,0.58,0.36)),
}
nodes = []
def c3(c): return "Color(%.3f, %.3f, %.3f, 1)" % c
def tf(x,y,z, rx=0.0, ry=0.0, s=1.0):
    cx,sx=math.cos(rx),math.sin(rx); cy,sy=math.cos(ry),math.sin(ry)
    X=(1,0,0); Y=(0,cx,sx); Z=(0,-sx,cx)
    def ry_(v): return (cy*v[0]+sy*v[2], v[1], -sy*v[0]+cy*v[2])
    X,Y,Z = [tuple(c*s for c in ry_(v)) for v in (X,Y,Z)]
    f=lambda v: ", ".join("%.6g"%c for c in v)
    return "Transform3D(%s, %s, %s, %s)" % (f(X),f(Y),f(Z),f((x,y,z)))
def box(name, parent, x,y,z, sx,sy,sz, mat, rx=0.0, ry=0.0):
    nodes.append(f'''[node name="{name}" type="CSGBox3D" parent="{parent}"]
transform = {tf(x,y,z,rx,ry)}
use_collision = true
size = Vector3({sx}, {sy}, {sz})
material = SubResource("m_{mat}")
''')
def top_box(name,parent,cx,top,cz,sx,sy,sz,mat): box(name,parent,cx,top-sy/2,cz,sx,sy,sz,mat)
def label(name, x,y,z, text, size=64):
    nodes.append(f'''[node name="{name}" type="Label3D" parent="Labels"]
transform = {tf(x,y,z)}
billboard = 1
modulate = Color(1, 1, 1, 0.9)
font_size = {size}
outline_size = 18
outline_modulate = Color(0.15, 0.2, 0.35, 1)
text = "{text}"
''')
deco_n = {}
def deco(kind, x, y, z, s=1.0, ry=None, parent="Decor", collide=None):
    deco_n[kind] = deco_n.get(kind, 0) + 1
    name = f"{kind}_{deco_n[kind]}"
    if ry is None: ry = random.uniform(0, math.tau)
    if collide:
        shape, off = collide
        nodes.append(f'''[node name="{name}" type="StaticBody3D" parent="{parent}"]
transform = {tf(x,y,z,0,ry)}

[node name="Model" parent="{parent}/{name}" instance=ExtResource("d_{kind}")]
transform = {tf(0,0,0,0,0,s)}

[node name="Shape" type="CollisionShape3D" parent="{parent}/{name}"]
transform = {tf(0,off,0)}
shape = SubResource("{shape}")
''')
    else:
        nodes.append(f'''[node name="{name}" parent="{parent}" instance=ExtResource("d_{kind}")]
transform = {tf(x,y,z,0,ry,s)}
''')
def tree(x,y,z,s=0.55, fruit=False): deco("Tree_Fruit" if fruit else "Tree", x,y,z,s, collide=("trunk",1.2))
def bush(x,y,z,s=0.42): deco(random.choice(["Bush","Bush_Fruit"]), x,y,z,s)
def grass(x,y,z):
    # Çimen modellerinin tabanı modelin içinde ~0,92 m yukarıda; zemine indir.
    s = random.uniform(0.9,1.3)
    deco(random.choice(["Grass_1","Grass_2","Grass_3"]), x,y-0.92*s,z,s)
def rock(x,y,z,s=0.7): deco(random.choice(["Rock_1","Rock_2"]), x,y,z,s, collide=("rock",0.35*s/0.7))
def scatter_grass(x0,x1,z0,z1,y,n,avoid=()):
    k=0; tries=0
    while k<n and tries<500:
        tries+=1
        x=random.uniform(x0,x1); z=random.uniform(z0,z1)
        if any(a[0]<=x<=a[1] and a[2]<=z<=a[3] for a in avoid): continue
        grass(x,y,z); k+=1

# --- A: başlangıç alanı (z +10 .. -10), üst yüzey y=0 ---
P="Level/A_Baslangic"
top_box("Zemin",P,0,0,0,18,3,20,"grass")
for i,h in enumerate([0.5,1.0,1.5,2.0]):
    z = 3 - i*3.5
    top_box(f"Basamak_{str(h).replace('.','_')}m",P,-6,h,z,3,h,2.5,["grass2","grass2","yellow","yellow"][i])
    label(f"L_basamak{i}",-6,h+0.8,z,f"{str(h).replace('.',',')} m")
L=6.0
for name,deg,z,mat in [("Rampa_30derece",30,2.0,"grass2"),("Rampa_50derece",50,-5.0,"stone")]:
    a=math.radians(deg); h=L*math.sin(a); d=L*math.cos(a)
    box(name,P,6.5,h/2-0.2*math.cos(a),z,3,0.4,L,mat,rx=a)
    label(f"L_{name}",6.5,h+0.8,z-d/2+0.3,f"{deg}°")
top_box("AlcakTavan",P,0,3.0,-6,4,0.4,3,"wood")
top_box("AlcakTavan_DirekL",P,-2.2,2.6,-6,0.4,2.6,0.4,"wood")
top_box("AlcakTavan_DirekR",P,2.2,2.6,-6,0.4,2.6,0.4,"wood")
label("L_tavan",0,3.7,-6,"tavan 2,6 m")
# Süs: ağaçlar, çalılar, kayalar, çimen
tree(-8.0,0,8.5,0.6,True); tree(8.0,0,8.8,0.5); tree(-8.0,0,-8.6,0.45)
bush(-6.0,0,9.0,0.35); bush(8.3,0,6.5,0.38); bush(-8.4,0,4.2,0.32); bush(3.6,0,-9.0,0.35)
rock(8.2,0,-9.0,0.6); rock(-3.8,0,-9.2,0.45)
scatter_grass(-8.5,8.5,-9.5,9.5,0,26,avoid=[(-2.5,2.5,-10,10),(-7.8,-4.2,-6,5),(4.5,8.5,-9,5.5)])
deco("Arrow",3.0,0,-9.3,0.8,math.pi, parent="Decor")

# --- B: boşluklar 2 m, 3 m, 4 m ---
P="Level/B_Bosluklar"
z0=-10
for gap,depth in [(2,6),(3,6),(4,6)]:
    zs=z0-gap; ze=zs-depth
    top_box(f"Ada_bosluk_{gap}m",P,0,0,(zs+ze)/2,6,3,depth,"grass")
    label(f"L_bosluk{gap}",0,1.4,z0-gap/2,f"{gap} m"+(" (zor)" if gap==4 else ""))
    grass(-2.6,0,zs-0.6); grass(2.5,0,ze+0.7); bush(2.4,0,(zs+ze)/2,0.3)
    z0=ze
top_box("Ada_basamak_1_5m",P,0,1.5,z0-2-3,6,4.5,6,"sand")
label("L_bosluk_basamak",0,3.0,z0-1,"2 m + 1,5 m")
rock(2.2,1.5,z0-6.6,0.5); grass(-2.3,1.5,z0-3)
z_after = z0-2-6
# --- C: hareketli platform ---
nodes.append(f'''[node name="HareketliPlatform" type="AnimatableBody3D" parent="Level/C_Hareketli"]
transform = {tf(0,1.25,z_after-2)}
script = ExtResource("mp")
offset = Vector3(0, 0, -6)
duration = 2.5

[node name="Mesh" type="MeshInstance3D" parent="Level/C_Hareketli/HareketliPlatform"]
mesh = SubResource("mp_mesh")

[node name="Shape" type="CollisionShape3D" parent="Level/C_Hareketli/HareketliPlatform"]
shape = SubResource("mp_shape")
''')
plaza_z = z_after-11
P="Level/D_Plaza"
top_box("Plaza",P,0,1.5,plaza_z-10,24,4.5,20,"grass")
label("L_hareketli",0,3.5,z_after-1,"hareketli platform")
for side in (-1,1):
    top_box(f"KoridorDuvar_{'L' if side<0 else 'R'}",P,-7+side*2,7.5,plaza_z-10,1,6,14,"stone")
top_box("KoridorTavan",P,-7,8,plaza_z-10,5,0.5,14,"stone")
label("L_koridor",-7,8.7,plaza_z-2.5,"dar koridor")
cx,cz=7,plaza_z-12
for i in range(8):
    ang=i*math.pi/3
    top_box(f"KuleBasamak_{i+1}",P,cx+math.cos(ang)*3.2,1.5+1.0*(i+1),cz+math.sin(ang)*3.2,2.2,1.0*(i+1),2.2,"yellow" if i%2 else "grass2")
top_box("KuleOrta",P,cx,10.5,cz,2.5,9,2.5,"stone")
deco("Goal_Flag",cx,10.5,cz,0.9,0.5)
label("L_kule",cx,13.2,cz,"kule 9 m")
top_box("BolgePlatform",P,0,1.5,plaza_z-24,8,4.5,8,"purple")
nodes.append(f'''[node name="KameraBolgesi" type="Area3D" parent="Level/D_Plaza"]
transform = {tf(0,3.5,plaza_z-24)}
script = ExtResource("cz")
yaw_deg = 90.0
pitch_deg = 30.0
distance = 10.0

[node name="Shape" type="CollisionShape3D" parent="Level/D_Plaza/KameraBolgesi"]
shape = SubResource("zone_shape")
''')
label("L_bolge",0,4.3,plaza_z-20.5,"kamera bölgesi")
tree(10.5,1.5,plaza_z-1.5,0.55,True); tree(-11,1.5,plaza_z-18.5,0.5); tree(1.5,1.5,plaza_z-18.2,0.45)
bush(-2.5,1.5,plaza_z-1.2); bush(10.6,1.5,plaza_z-19); bush(-10.8,1.5,plaza_z-1.5,0.35); bush(2.6,1.5,plaza_z-27.2,0.3)
rock(-2.8,1.5,plaza_z-18.8,0.6); rock(11,1.5,plaza_z-8,0.5)
deco("Plant_Large",3.2,1.5,plaza_z-21.2,0.8); deco("Plant_Small",-3.2,1.5,plaza_z-21.5,0.8)
scatter_grass(-11.5,11.5,plaza_z-19.5,plaza_z-0.5,1.5,28,avoid=[(-9.6,-4.4,plaza_z-17.5,plaza_z-2.5),(2.5,11.5,plaza_z-17,plaza_z-7),(-2.5,2.5,plaza_z-20,plaza_z)])
# Bulutlar: aşağıda ve uzakta
# Oyun alanından (x=-13..13, z=+12..-80) uzak dursunlar ki kamerayı kapatmasınlar.
k=0
while k<24:
    x=random.uniform(-75,75); z=random.uniform(-130,60)
    if abs(x) < 26 and -95 < z < 30: continue
    y=random.choice([random.uniform(-4.0,-2.5), random.uniform(8,20)])
    k+=1
    deco(random.choice(["Cloud_1","Cloud_2","Cloud_3"]), x,y,z, random.uniform(1.6,3.2), parent="Clouds")

kinds = sorted(deco_n.keys())
ext = '''[ext_resource type="Script" path="res://scripts/level/test_area.gd" id="lvl"]
[ext_resource type="PackedScene" path="res://scenes/player/bip.tscn" id="bip"]
[ext_resource type="PackedScene" path="res://scenes/camera/follow_camera.tscn" id="cam"]
[ext_resource type="PackedScene" path="res://scenes/ui/touch_controls.tscn" id="touch"]
[ext_resource type="Shader" path="res://assets/shaders/toon_terrain.gdshader" id="sh"]
[ext_resource type="Shader" path="res://assets/shaders/water.gdshader" id="water"]
[ext_resource type="Script" path="res://scripts/level/moving_platform.gd" id="mp"]
[ext_resource type="Script" path="res://scripts/level/camera_zone.gd" id="cz"]
[ext_resource type="AudioStream" path="res://assets/audio/opengameart/happy_clappy_loop.mp3" id="music"]
[ext_resource type="AudioStream" path="res://assets/audio/kenney/fall.ogg" id="fall"]
[ext_resource type="Script" path="res://scripts/ui/pause_menu.gd" id="pause"]
''' + "".join(f'[ext_resource type="PackedScene" path="res://assets/models/quaternius/platformer/{k}.gltf" id="d_{k}"]\n' for k in kinds)
subs=[]
for k,(t1,t2,a,b) in themes.items():
    subs.append(f'''[sub_resource type="ShaderMaterial" id="m_{k}"]
render_priority = 0
shader = ExtResource("sh")
shader_parameter/top_color = {c3(t1)}
shader_parameter/top_color2 = {c3(t2)}
shader_parameter/side_a = {c3(a)}
shader_parameter/side_b = {c3(b)}
''')
subs.append('''[sub_resource type="BoxMesh" id="mp_mesh"]
material = SubResource("m_wood")
size = Vector3(4, 0.5, 4)

[sub_resource type="BoxShape3D" id="mp_shape"]
size = Vector3(4, 0.5, 4)

[sub_resource type="BoxShape3D" id="zone_shape"]
size = Vector3(8, 4, 8)

[sub_resource type="CylinderShape3D" id="trunk"]
height = 2.4
radius = 0.35

[sub_resource type="SphereShape3D" id="rock"]
radius = 0.45

[sub_resource type="ShaderMaterial" id="water_mat"]
render_priority = 0
shader = ExtResource("water")

[sub_resource type="PlaneMesh" id="water_mesh"]
material = SubResource("water_mat")
size = Vector2(400, 400)
subdivide_width = 60
subdivide_depth = 60

[sub_resource type="ProceduralSkyMaterial" id="sky_mat"]
sky_top_color = Color(0.25, 0.55, 0.95, 1)
sky_horizon_color = Color(0.72, 0.88, 1, 1)
sky_curve = 0.12
ground_bottom_color = Color(0.2, 0.45, 0.75, 1)
ground_horizon_color = Color(0.72, 0.88, 1, 1)
sun_angle_max = 20.0

[sub_resource type="Sky" id="sky"]
sky_material = SubResource("sky_mat")

[sub_resource type="Environment" id="env"]
background_mode = 2
sky = SubResource("sky")
ambient_light_source = 3
ambient_light_color = Color(1, 1, 1, 1)
ambient_light_sky_contribution = 0.6
ambient_light_energy = 1.1
tonemap_mode = 2
tonemap_white = 6.0
glow_enabled = true
glow_intensity = 0.4
glow_bloom = 0.05
fog_enabled = true
fog_light_color = Color(0.72, 0.86, 1, 1)
fog_density = 0.0035
fog_sky_affect = 0.0
adjustment_enabled = true
adjustment_saturation = 1.12
''')
root = f'''[node name="TestArea" type="Node3D"]
script = ExtResource("lvl")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("env")

[node name="Sun" type="DirectionalLight3D" parent="."]
transform = {tf(0,10,0,math.radians(-50),math.radians(30))}
light_color = Color(1, 0.96, 0.88, 1)
light_energy = 1.25
shadow_enabled = true
shadow_blur = 1.5
directional_shadow_mode = 0
directional_shadow_max_distance = 45.0

[node name="Water" type="MeshInstance3D" parent="."]
transform = {tf(0,-6,-30)}
mesh = SubResource("water_mesh")
cast_shadow = 0

[node name="Music" type="AudioStreamPlayer" parent="."]
stream = ExtResource("music")
bus = &"Music"

[node name="FallSfx" type="AudioStreamPlayer" parent="."]
stream = ExtResource("fall")
volume_db = -4.0
bus = &"SFX"

[node name="SpawnPoint" type="Marker3D" parent="."]
transform = {tf(0,0.05,6,0,math.pi)}

[node name="Bip" parent="." node_paths=PackedStringArray("camera_rig") instance=ExtResource("bip")]
transform = {tf(0,0.05,6,0,math.pi)}
camera_rig = NodePath("../FollowCamera")

[node name="FollowCamera" parent="." node_paths=PackedStringArray("target") instance=ExtResource("cam")]
target = NodePath("../Bip")

[node name="UI" type="CanvasLayer" parent="."]

[node name="TouchControls" parent="UI" instance=ExtResource("touch")]

[node name="PauseMenu" type="Control" parent="UI"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("pause")

[node name="Help" type="Label" parent="UI"]
offset_left = 16.0
offset_top = 12.0
offset_right = 900.0
offset_bottom = 60.0
theme_override_colors/font_outline_color = Color(0.1, 0.15, 0.3, 1)
theme_override_constants/outline_size = 8
theme_override_font_sizes/font_size = 18
text = "WASD: koş · Boşluk: zıpla · Fare/oklar: kamera (tıkla) · R: başa dön · M: müzik · Esc: duraklat"

[node name="Level" type="Node3D" parent="."]

[node name="A_Baslangic" type="Node3D" parent="Level"]

[node name="B_Bosluklar" type="Node3D" parent="Level"]

[node name="C_Hareketli" type="Node3D" parent="Level"]

[node name="D_Plaza" type="Node3D" parent="Level"]

[node name="Decor" type="Node3D" parent="."]

[node name="Clouds" type="Node3D" parent="."]

[node name="Labels" type="Node3D" parent="."]
'''
with open(OUT,"w") as f:
    f.write("[gd_scene format=3]\n\n" + ext + "\n" + "\n".join(subs) + "\n" + root + "\n" + "\n".join(nodes))
print("yazıldı:", os.path.normpath(OUT), "süs sayıları:", deco_n)
