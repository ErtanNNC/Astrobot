# Mağaza metinleri (Google Play / App Store)

## Kısa açıklama (≤ 80 karakter)
TR: Kopyalayan küçük robot Bip ile renkli 3B platform macerası!
EN: A colorful 3D platform adventure with Bip, the little robot who copies!

## Uzun açıklama (TR)
Fırtınada anteni yıldırım çarpan küçük tamir robotu Bip artık dokunduğu nesnelerin yeteneğini **kopyalayabiliyor**! Karanlığa gömülen Dişli Adası'na ışığı geri getirmek için yola çık.

• **Altı yetenek:** Yay ile yükseğe sek, Balon ile süzül, Mıknatıs ile metale yapış, Kaya ile ağır kapıları aç, Pervane ile uç, Buz ile suyun ve lavın üstünde yürü.
• **5 bölüm, 20 alan:** çiçekli bahçeler, gün batımı kanyonu, oyuncak fabrika, liman kasabası, buzlu göller, fırtına köprüleri, bulutların üstündeki kale ve final sonrası açılan Gizli Adalar.
• **Dört patron**, her biri yeteneklerini yeni bir biçimde kullandırır.
• **Gizli köşeler:** her alanda bir Altın Vida ve saklı pil sandıkları; kurtarılmayı bekleyen robotlar.
• **Kostüm Dolabı:** topladığın pillerle Bip'e yeni renkler aç.
• **Telefon için tasarlandı:** büyük, başparmağa yakın butonlar; ayarlanabilir buton boyutu ve sol el modu. Gamepad ve klavye desteği.
• Reklam yok, internet gerekmez, veri toplanmaz.

## Long description (EN)
During a storm, lightning strikes the antenna of Bip, a tiny repair robot — and now Bip can **copy** the ability of anything it touches! Bring the light back to Gear Island.

• **Six abilities:** bounce with Spring, glide with Balloon, stick to metal with Magnet, smash with Rock, fly with Propeller, walk on water and lava with Ice.
• **5 chapters, 20 areas**, four bosses and a bonus chapter unlocked after the finale.
• **Secrets everywhere:** a Golden Screw in every area, hidden battery crates and lost robots to rescue.
• **Costume closet:** unlock new colors for Bip with the batteries you collect.
• **Made for phones:** big thumb-friendly buttons, adjustable size, left-handed mode; gamepad and keyboard supported.
• No ads, no internet required, no data collected.

## Ekran görüntüleri ve öne çıkan görsel
- Ekran görüntüleri: `build/magaza/01..08_*.png` (1920×1080, oyun içinden, yazı afişi yok). Yeniden üretmek için `GODOT=... tools/store/make_shots.sh`. Oyun yatay olduğu için yatay görüntüler kullanılır.
- Öne çıkan görsel (Google Play, 1024×500): `build/magaza/one_cikan_tr.png` ve `one_cikan_en.png`. Üretici: `python3 tools/store/feature_graphic.py "Oyun Adı"` (isim değişince tek komutla yenilenir).
- Simge: `icon.png` (512×512), uyarlanabilir simge katmanları `assets/ui/icon_fg_432.png`, `icon_bg_432.png`.

## Tanıtım videosu (30 saniye, yatay) — çekim listesi
Video bu ortamda çekilemedi (ekran kaydı yok); telefonda ya da PC'de ekran kaydıyla şu sırayla çekilmeli. Yazılar videoya sonradan eklenir.

| Sn | Görüntü | Alan | Yazı (TR / EN) |
|---|---|---|---|
| 0–3 | Bip uyanır, anteni parlar, kameraya el sallar | Uyanış Atölyesi (açılış) | "Bip uyanıyor!" / "Bip wakes up!" |
| 3–8 | Yay kopyalanır, 4 m'lik zıplayışla terasa çıkılır | Yay Bahçesi | "Yeteneği kopyala" / "Copy the power" |
| 8–12 | Balon ile kanyonun üstünden süzülüş | Balon Kanyonu | "Süzül" / "Glide" |
| 12–16 | Mıknatıs zincirinde bloktan bloğa | Mıknatıs Fabrikası | "Çekil" / "Swing" |
| 16–20 | Buz ile lavın üstünde yürüyüş | Volkan Adası | "Dondur" / "Freeze" |
| 20–25 | Patron: uyarı diski dolar, Bip kaçar, patrona vurur | Hurdacı Vinç ya da Kardan Dev | "Patronları yen" / "Beat the bosses" |
| 25–28 | Kostüm Dolabı: renkler ve koşu izleri hızlıca değişir | Atölye | "7 kostüm, 4 iz" / "7 skins, 4 trails" |
| 28–30 | Öne çıkan görsel + oyun adı + "Ücretsiz" | | |

Kurallar: ilk 3 saniyede oynanış görünmeli (mağaza videoyu sessiz ve otomatik oynatır); dokunmatik butonlar görünür kalsın (gerçek telefon oyunu olduğu anlaşılır); müzik `happy_clappy_loop` (CC0).

## Oyunun adı
"Bip" tek başına mağazada bulunmaz: Türkiye'de "BiP" bilinen bir mesajlaşma uygulaması, aramada onun altında kalır ve marka itirazı riski var. Öneriler (hiçbiri marka veritabanında kontrol edilmedi; karar ve kontrol geliştiricide):
1. **Bip: Dişli Adası** / *Bip: Gear Island* — karakter adı kalır, arama ayrışır. Önerilen.
2. **Robot Bip'in Macerası** / *Bip the Copy Bot*
3. **Kopya Robot** / *Copy Bot Island*
İsim seçilince: `project.godot` (uygulama adı), `export_presets.cfg` (paket adı değişirse eski APK'nın üstüne kurulmaz), giriş ekranı başlığı, `tools/store/feature_graphic.py` argümanı, bu dosya.

## Kategori / yaş
Oyun › Macera (Platform). Yaş: 3+ / Herkes. İçerik: hafif çizgi film şiddeti (düşmanların üstüne zıplamak).

## Mağazaya göndermeden önce
- `export_presets.cfg` içindeki `custom_features="dev"` etiketini sil: "Tüm alanlar açık (test)" seçeneği kendiliğinden kaybolur (2026-11-21'den beri yalnızca bu etiketle görünür).
- Lisans denetimi: `docs/store/lisans-denetimi.md`.
- Google Play: AAB gerekir (bu ortamda Android SDK yok; Android Studio + Godot dışa aktarma ile). Yeni bir yükleme anahtarı oluştur ve **repoda tutma**.
- iOS: Mac + Xcode gerekir.
- Gizlilik politikası: `docs/store/gizlilik-politikasi.md` bir web sayfasında yayımlanmalı (ör. GitHub Pages).
