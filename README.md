# Bip

Anteniyle dokunduğu nesnenin yeteneğini kopyalayan küçük robot Bip'in 3D platform oyunu.
Tasarım: [docs/GDD.md](docs/GDD.md) · Claude için kurallar: [CLAUDE.md](CLAUDE.md)

**Şu anki durum:** giriş ekranı + Atölye ana menüsü, 3 kayıt yuvası, açılış/kapanış sahneleri,
Bölüm 1 Uyanış (öğretici + 4 alan + Hurdacı Vinç), Bölüm 2 Fırtına Limanı (3 alan + Paslı Kaptan),
Bölüm 3 Buzul Tepesi (3 alan + Kardan Dev), Bölüm 4 Fırtınanın Gözü (2 alan + Statik), final ve Emeği Geçenler; 6 yetenek.

## Oyun nasıl oynanır
Bip, anteniyle dokunduğu parlayan nesnelerin yeteneğini kopyalar. Aynı anda tek yetenek taşınır;
hasar alınca önce yetenek gider, yetenek yoksa can. Her alanda piller ve gizli bir Altın Vida var.

| Yetenek | Nereden | Ne yapar |
|---|---|---|
| Yay | yay | 5 m zıplama; yerde Yetenek basılı tut + bırak = 6,5 m şarjlı zıplama |
| Balon | balon | havada zıplamayı basılı tut = süzülme (rüzgâr seni yukarı taşır) |
| Mıknatıs | mıknatıs | Yetenek = en yakın metal yüzeye çekil ve yapış; zıpla = ayrıl; piller sana gelir |
| Kaya | kaya | ağır ve yavaş; havada Yetenek = yere çakıl (çatlak zemin kırılır, düşman ezilir, ağır buton basılır); suda batar |
| Pervane | rüzgâr gülü | havada zıplamayı basılı tut = yüksel; havada Yetenek = ileri atıl |
| Buz | buz kristali | suyun üstünde yürü; Yetenek = yakındaki düşmanı dondur (üstüne çıkılır) |

Yeteneği bırakmak: Yetenek tuşunu 1,2 sn basılı tut.

## Bilgisayarda açmak
1. [godotengine.org](https://godotengine.org/download) adresinden **Godot 4.7.2** (standart sürüm, .NET değil) indir.
2. Godot'yu aç → **İçe Aktar** → bu klasördeki `project.godot` dosyasını seç → **İçe Aktar ve Düzenle**.
3. Sağ üstteki **▶ (F5)** düğmesine bas. Test alanı açılır.

### Kontroller (PC)
| Tuş | İş |
|---|---|
| W A S D | koş (kameraya göre) |
| Boşluk | zıpla (basılı tut = yüksek, kısa bas = alçak) |
| E | Yetenek: parlayan nesneyi kopyala / yeteneği kullan |
| Fare (önce oyun ekranına tıkla) / ok tuşları | kamerayı döndür; 2 sn dokunmazsan kamera kendi döner |
| R | başa dön |
| M | müziği aç/kapat |
| Esc | duraklat (fare de serbest kalır) |

Gamepad: sol çubuk koş, A zıpla, X yetenek, sağ çubuk kamera, Start duraklat.

### Telefonda (APK)
| Yer | İş |
|---|---|
| Sol yarı (nereye dokunursan) | joystick belirir, Bip'i yürüt |
| Sağ alttaki büyük ▲ | zıpla (basılı tut = yüksek) |
| Onun sol üstündeki anten | Yetenek (M2'de çalışacak, şimdilik soluk) |
| Sağ yarıda kaydır | kamerayı çevir |
| Sol üstteki ‖ | duraklat: Devam, Baştan başla, Ayarlar (buton boyutu, sol el modu, titreşim, müzik, efektler) |

Ayrıntılar: [docs/features/mobil-kontroller/design.md](docs/features/mobil-kontroller/design.md)

## Otomatik testler
```
godot --headless --path . tests/compile_check.tscn   # tüm betik ve sahneler yükleniyor mu
godot --headless --path . tests/m2_test.tscn          # Yay, hasar, düşman, pil
godot --headless --path . tests/abilities_test.tscn   # Pervane, Buz, yüzme
godot --headless --path . tests/boss_test.tscn        # Hurdacı Vinç'in 3 aşaması
```

## Eski M1 test alanı
- **Başlangıç:** 0,5 / 1,0 / 1,5 / 2,0 m basamaklar, 30° (çıkılır) ve 50° (duvar) rampalar, 2,6 m yükseklikte alçak tavan.
- **Boşluklar:** 2 m, 3 m, 4 m (zor) boşluklar, sonra 2 m boşluk + 1,5 m basamak.
- **Hareketli platform**, üstünde taşınmayı test etmek için.
- **Plaza:** dar koridor (kamera duvardan kaçıyor mu), 9 m'lik spiral kule (kamera yüksekliği), kamera bölgesi (sarı platform).
- Denize düşersen başa dönersin.

## Seviyeyi yeniden üretmek
`tools/level/gen_test_area.py` test alanı sahnesini baştan yazar. Sahneyi editörde elle değiştirdiysen çalıştırma; değişikliklerin silinir.

## Sayıları değiştirmek
Sahnede **Bip**'i seç → sağdaki **Inspector**'da "Koşu", "Zıplama" gruplarındaki sayılar.
Kamera için **FollowCamera**'yı seç. Değiştirdiğin sayıyı `docs/features/.../design.md` dosyasına da yaz.

## Otomatik test
```
godot --headless --path . -s tests/m1_movement_test.gd
```
2 m boşluk, 1,5 m basamak, coyote time ve zıplama tamponunu kontrol eder.

## Android APK
`tools/android/README.md` dosyasına bak.
