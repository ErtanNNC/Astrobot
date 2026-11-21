# Ses

Durum: oyunda (2026-11-21). Kod: `scripts/autoload/sfx.gd` (kısa efektler), `scripts/level/area.gd` (müzik, ortam),
`scripts/player/bip_visuals.gd` (adım, zıplama, iniş), `scripts/ui/pause_menu.gd` (duraklatınca kısma).

## Katmanlar
| Katman | Ne | Ses yolu (bus) |
|---|---|---|
| Müzik | alan başına bir döngü (`area.AREA_MUSIC`) | Music |
| Ortam | alanın yerini anlatan kısık döngü (`area.AREA_AMBIENT`) | SFX |
| Efekt | pil, zıplama, hasar, düşman, arayüz (`Sfx.SOUNDS`) | SFX |
| Adım | Bip'in bastığı zemine göre | SFX |

## Kurallar
1. **Müzik geçişi:** alan açılınca müzik 1,2 saniyede yükselir; alan bitince 0,8 saniyede kısılır ki bitiş cıngılı duyulsun. Patron dövüşü başlayınca müzik 0,6 saniyede biraz yükselir.
2. **Duraklatma:** duraklatınca müzik 9 dB kısılır, devam edince geri gelir.
3. **Ortam sesi** müziğin altında kalır (-9 dB), 2 saniyede açılır. Efekt ses ayarına bağlıdır.
4. **Adım sesi:** her 1,75 m yolda bir adım (en sık 0,2 sn, en seyrek 0,45 sn). Örnek, ses ve perde zemine göre seçilir; her adımda perde ±%8 oynar.
5. Metal blokların üstünde "metal", hareketli platformların üstünde "tahta" sesi çıkar; gerisi alanın zeminidir.

## Sayılar
| Ad | Değer | Birim |
|---|---|---|
| Müzik açılış süresi | 1,2 | s |
| Müzik kapanış süresi | 0,8 | s |
| Duraklatınca kısma | 9 | dB |
| Ortam sesi düzeyi | -9 | dB |
| Adım aralığı | 1,75 | m |

## Zemin ve ortam tablosu
| Alanlar | Zemin | Ortam |
|---|---|---|
| Uyanış Atölyesi | tahta | (yok) |
| Yay Bahçesi | çimen | kuşlar |
| Balon Kanyonu, Kaya Ocağı, Bölüm 1 patronu | çakıl | rüzgâr |
| Mıknatıs Fabrikası | taş | makine uğultusu |
| Bölüm 2 (Rıhtım, Gemi, patron) | tahta | dalga |
| Fener | çimen | dalga |
| Bölüm 3 | kar | mağara (Buz Mağarası), rüzgâr (diğerleri) |
| Bulut Basamakları | bulut (çok kısık) | rüzgâr |
| Fırtına Köprüleri, Kıvılcım Kalesi, Bölüm 4 patronu | taş | yağmur |
| Oyuncak Kasabası, Şampiyon Yolu | tahta | kuşlar / rüzgâr |
| Yıldız Gözlemevi | taş | mağara |
| Volkan Adası | çakıl | uğultu |

## Kaynaklar
Hepsi CC0, OpenGameArt; liste CREDITS.md içinde. Ortam döngüleri özgün kayıtlardan 9–24 saniyelik, başı sonuna
karıştırılmış (dikişsiz), tek kanallı parçalara indirildi (toplam ~0,8 MB).

## Açık konular
- Kar için gerçek bir "kar gıcırtısı" örneği yok; çamur + yaprak örneği kalın perdede kullanılıyor.
- Sesler bu ortamda dinlenemedi (ses kartı yok); düzeyler telefonda kontrol edilmeli.
