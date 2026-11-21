# Bölüm 5: Gizli Adalar (bonus)

Final (Statik) bittikten sonra açılan bonus bölüm. Hikâyeye bağlı değildir; patron yoktur. Altı yeteneğin hepsini yeni ortamlarda, karışık ve oyuncak gibi eğlenceli biçimde kullandırır. Final kapanışı bittiğinde kayıt bu bölümün ilk alanına geçer (`closing.gd`), Atölye kapısı oradan devam eder. Son alanın çıkışı bölüm sonuç ekranına gider.

## Alanlar
| # | Alan | Süre | Öğret | Sına | Şaşırt | Ustalık |
|---|---|---|---|---|---|---|
| 1 | Oyuncak Kasabası | ~6 dk | Yay ile dev hediye kutuları (4 m) | oyuncak tren (hareketli vagon) | Balon ile kaleye süzülüş | Mıknatıs levhalarıyla kule, Pervane ile Fındıkkıran'ın şapkası |

## Oyuncak Kasabası (2026-11-21)
Üretici: `tools/level/ch5_e1_oyuncak_kasabasi.py`, kimlik `ch5_oyuncak`. Dev bir oyun masasının üstünde havada duran oyuncaklar: KayKit Holiday hediye kutuları (görüntü) + ölçülü çarpışma kutuları, ahşap raflar, kırmızı vagon + lokomotif modelli hareketli platform (`prop` kind=model platformun çocuğu), oyuncak kale. Yön işareti: masanın üstünde duran dev **Fındıkkıran** (Kenney Holiday Kit), bitiş platformu şapkasının hemen önünde.

| # | Bölüm | Ne yapılır |
|---|---|---|
| 0 | Oyun Halısı | Yay kopyalanır |
| 1 | Hediye Kulesi | üç 4 m'lik hediye kutusu, Yay ile |
| 2 | Oyuncak Rafı ve Tren | kontrol noktası "raf"; vagon 10 m'lik boşluğu taşır |
| 3 | Kaleye süzülüş | 12 m Balon, kontrol noktası "kale" |
| 4 | Kale kulesi | üç metal levha (Mıknatıs), kontrol noktası "kule" |
| 5 | Fındıkkıran'ın şapkası | Pervane ile 6,5 m, bitiş |

**Gizli köşeler (3):** top havuzu (başlangıcın arkasında aşağıda; trambolinle dön; 12 pil), şeker kamışı sütunu (yeşil kutudan doğuya Yay; **Altın Vida**), trenin altındaki gizli raf (raf 1'in ucundan in; trambolinle dön; 10 pil).

## Rules
1. Bonus bölüm yalnızca final bittikten sonra açılır.
2. Bölüm 1'in kuralları geçerlidir (kontrol noktaları, 3 can, piller kaybolmaz, testere dişi zorluk).
3. Her alanda bir Altın Vida.

## Numbers
| Ad | Değer | Birim | Not |
|---|---|---|---|
| Hediye kutusu yüksekliği | 4 | m | Yay basamağı |
| Tren yolu | 10 | m | 3 sn tek yön |
| Öldürme yüksekliği | −6 | m | masa −8'de, görünür ama ölümcül |

## Test
`tests/ch5_test.tscn`: üç kutu, Altın Vida sütunu, tren, Balon, Mıknatıs, Pervane, iki gizli köşeden dönüş.

## History
- 2026-11-21: bölüm ve ilk alan (Oyuncak Kasabası) eklendi.
