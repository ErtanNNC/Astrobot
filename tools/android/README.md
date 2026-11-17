# Android APK üretimi

```
GODOT=/yol/godot tools/android/build_apk.sh
```
Çıktı: `build/Bip-0.<kilometre taşı>.<sürüm kodu>.apk`

## Neden yeni APK eskisinin üstüne kuruluyor?
Android bir uygulamayı güncelleme olarak kabul etmek için üç şey ister:
1. **Aynı paket adı:** `io.github.ertannnc.bip` (`export_presets.cfg`, değiştirme).
2. **Aynı imza anahtarı:** `tools/android/keystore/bip-release.p12`. Anahtar kaybolursa
   yeni APK'lar eskisinin üstüne kurulamaz; eski uygulamayı silip yeniden kurmak gerekir.
   **Anahtarı ve şifresini güvenli bir yerde yedekle.**
3. **Daha büyük sürüm kodu:** betik sürüm kodunu git commit sayısından alır; her yeni
   commit'ten sonra alınan APK'nın kodu bir öncekinden büyüktür.

## İmzalama hakkında
Godot normalde Android SDK'daki `apksigner` ile imzalar. Bu betik SDK gerektirmeden,
Google'ın `apksig` kütüphanesiyle (`ApkSign.java`) v2 imzası atar (Android 7+ için yeterli;
oyunun en düşük sürümü zaten Android 7, API 24).
Bilgisayarında Android SDK kuruluysa Godot editöründen de dışa aktarabilirsin: Proje →
Dışa Aktar → Android → "Release keystore" alanına aynı `.p12` dosyasını, kullanıcı adına
`bip`, şifreye `password.txt` içeriğini yaz; sürüm kodunu da bir öncekinden büyük yap.

## Telefona kurmak
APK'yı telefona gönder, dosyaya dokun. İlk seferde "bilinmeyen kaynaklardan yükleme" izni
istenir. Sonraki sürümlerde "Güncelle" denir; eski kayıtlar korunur.
