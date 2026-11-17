# Bip

Anteniyle dokunduğu nesnenin yeteneğini kopyalayan küçük robot Bip'in 3D platform oyunu.
Tasarım: [docs/GDD.md](docs/GDD.md) · Claude için kurallar: [CLAUDE.md](CLAUDE.md)

**Şu anki durum: M1 (greybox hareket + kamera) tamam.**

## Bilgisayarda açmak
1. [godotengine.org](https://godotengine.org/download) adresinden **Godot 4.7.2** (standart sürüm, .NET değil) indir.
2. Godot'yu aç → **İçe Aktar** → bu klasördeki `project.godot` dosyasını seç → **İçe Aktar ve Düzenle**.
3. Sağ üstteki **▶ (F5)** düğmesine bas. Test alanı açılır.

### Kontroller (PC)
| Tuş | İş |
|---|---|
| W A S D | koş (kameraya göre) |
| Boşluk | zıpla (basılı tut = yüksek, kısa bas = alçak) |
| Fare (önce oyun ekranına tıkla) / ok tuşları | kamerayı döndür; 2 sn dokunmazsan kamera kendi döner |
| R | başa dön |
| Esc | fareyi serbest bırak |

Gamepad: sol çubuk koş, A zıpla, sağ çubuk kamera.

### Telefonda (APK)
Sol yarıda parmağını koy → joystick belirir. Sağ alttaki **ZIPLA**. Sağ yarıda parmak kaydır → kamera.

## Test alanında neler var
- **Başlangıç:** 0,5 / 1,0 / 1,5 / 2,0 m basamaklar, 30° (çıkılır) ve 50° (duvar) rampalar, 2,6 m yükseklikte alçak tavan.
- **Boşluklar:** 2 m, 3 m, 4 m (zor) boşluklar, sonra 2 m boşluk + 1,5 m basamak.
- **Hareketli platform**, üstünde taşınmayı test etmek için.
- **Plaza:** dar koridor (kamera duvardan kaçıyor mu), 9 m'lik spiral kule (kamera yüksekliği), kamera bölgesi (sarı platform).
- Aşağı düşersen başa dönersin.

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
