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

## Kayıt günlüğü
### 1. kayıt — 2026-11-22, sürüm 0.4.122, SM-S948B (3120×1440), kalite Orta, gölge açık, 4 tur
| Alan | Sonuç | Süre | Düşme | Hasar | Pil | Kare hızı (en düşük/ortalama) |
|---|---|---|---|---|---|---|
| Uyanış Atölyesi | bitti, 3 yıldız | 82 sn | 0 | 0 | 60/61 | 55/59 |
| Yay Bahçesi | bitti, 3 yıldız | 160 sn | 0 | 2 | 161/175 | 59/59 |
| Balon Kanyonu (1) | **Pil bitti** | 89 sn | 4 | 1 | | 59/59 |
| Balon Kanyonu (2) | bitti, 2 yıldız | 92 sn | 2 | 1 | 96/127 | 59/59 |

Bulgular ve yapılanlar:
- Balon Kanyonu'nda üç düşüş aynı yerde (Altın Vida çıkıntısı, x≈14 z≈-47) ve iki turda da aynı noktada (M2, kontrol noktasının yanı) yetenek kaybı: yeteneksiz kalınca çıkıntıdan dönülemiyor → **yetenek güvencesi** kuralı eklendi (`docs/features/kopyalama/design.md`), çıkıntıya ve Kayıp Balkon'a Balon kaynağı kondu, M2'deki Zıpzıp iniş noktasından uzaklaştırıldı.
- Düşen oyuncu kanyon dibindeki kaya yığınlarının üstünde kalabiliyordu (yeni süs çarpışması yüzünden; "en son zemin" yükseklikleri 2,4 ve -1,2) → o kayalar çarpışmasız yapıldı.
- Balon Kanyonu hedef süresi 185 sn çok boldu (ilk temiz tur 92 sn) → 120 sn. Atölye (82/110) ve Yay Bahçesi (160/180) yerinde.
- Kare hızı bu telefonda sorun değil (üst sınıf cihaz); zayıf cihaz verisi yok.
