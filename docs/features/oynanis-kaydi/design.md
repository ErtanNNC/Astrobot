# Oynanış kaydı (test verisi)

Durum: oyunda (2026-11-22). Kod: `scripts/autoload/play_log.gd` (statik sınıf), kancalar `scripts/level/area.gd`,
düğmeler `scripts/ui/pause_menu.gd`, çözücü `tools/playlog/decode.py`.

## Amaç
Sayılar (hedef süre, can, düşman yerleri) tahminle kondu. Geliştirici telefonda oynarken oyun her alan turunu kaydeder;
geliştirici kaydı paylaşır, sayılar veriye göre ayarlanır. Ekran görüntüsü atmaya gerek kalmadan zor yerler görünür.

## Kurallar
1. Kayıt **yalnızca telefonda** durur (`user://playlog.json`). Oyun hiçbir yere veri göndermez; internet izni kullanılmaz.
2. Paylaşım elle yapılır: Ayarlar → **"Oynanış kaydını kopyala"** kaydı panoya alır (`BIPLOG1:` ile başlayan tek satır,
   sıkıştırılmış). Geliştirici istediği yere yapıştırır.
3. Kayıtta kişisel bilgi yoktur. Bulunanlar: oyun sürümü, telefon modeli, ekran boyu, görüntü ayarı; her tur için alan,
   başlama anı, süre, nasıl bittiği, yıldız, pil, kontrol noktalarına varış süreleri, düşülen ve hasar alınan yerler
   (konum), "Pil bitti" sayısı, ortalama ve en düşük kare hızı, kolay mod açık mı.
4. En çok 300 tur tutulur (eskiler silinir); tur başına en çok 40 düşme ve 40 hasar noktası.
5. Kare hızı saniyede bir örneklenir; alanın ilk 3 saniyesi sayılmaz.
6. **"Tüm ilerlemeyi sil"** (Ayarlar, iki kez basılır) kayıt yuvalarını, hayaletleri, başarımları, günlük görevi, bonus
   pili, kostüm/şapka/iz seçimini ve oynanış kaydını siler. Ses, kontrol, dil ve görüntü ayarları kalır.
7. Tek seferlik temiz başlangıç: `Settings.CLEAN_START_ID` değişen sürüm ilk açılışta 6. maddedeki silmeyi kendisi yapar
   (2026-11-22 sürümünde geliştirici istedi). Mağaza sürümünde bu kimlik boş bırakılır.

## Kaydı okumak
`python3 tools/playlog/decode.py kayit.txt` alan başına özet basar (tur, bitirme, kaybetme, düşme, hasar, en iyi süre,
kare hızı, en çok düşülen yerler). `--json` ham veriyi verir. Konumlar dünya koordinatıdır; köşeli alanlarda tasarım
koordinatına `tests/turns.gd` mantığıyla çevrilir.

## Mağaza sürümü
Bu özellik test içindir. Mağazada kalacaksa gizlilik politikasına "cihazda tutulan, gönderilmeyen oynanış istatistiği"
olarak yazılmalı; kalmayacaksa iki düğme `Settings.dev_mode()` arkasına alınmalı. **Karar verilmedi.**

## Testler
`tests/replay_test.tscn`: tur yazılır, dışa aktarılır, geri çözülür, silinir.
