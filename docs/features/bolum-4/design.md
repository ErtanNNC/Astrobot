# Bölüm 4: Fırtınanın Gözü

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Son Çekirdek Pil, Statik'in kendisinde: adanın üstünde dönen fırtına bulutunun içinde, kıvılcımlardan bir kale. Yeni yetenek yok; bu bölüm altı yeteneğin **hepsini** karışık ve hızlı biçimde ister (ustalık bölümü). Sonunda Statik yenilmez, **ikna edilir** (hikaye, D-014): Bip ona jeneratörün fazla enerjisini verir, Statik adanın dost fırtınası olur.

## Alanlar
| # | Alan | Süre | İçerik |
|---|---|---|---|
| 1 | Bulut Basamakları | ~6 dk | gökyüzünde bulut adaları: kaybolan bulut platformlar (fall), rüzgâr akımları, Balon ve Pervane geçişleri, Yay ile bulut kuleleri, Zıpzıp'lar |
| 2 | Kıvılcım Kalesi | ~7 dk | metal duvarlı kale (Mıknatıs), testere ve diken tuzakları, Kaya ile ağır kapılar, zamanlı kapı koşusu, Buz ile dondurulan Hurda Goblin merdivenleri; sonunda altı yeteneği sırayla isteyen final parkuru |
| 1b | Fırtına Köprüleri (yeni, 2026-11-21) | ~6 dk | **yan rüzgâr**: köprülerde ritimle esen rüzgâr Bip'i boşluğa iter, Kaya ile dayanılır | Pervane kulesi, fırtına boşluğunda Mıknatıs zinciri | yan rüzgârda Balon süzülüşü (rüzgâr doğuya sürükler) | Yay ile Fırtına Kulesi'ne üç basamak |
| 3 | Patron: Statik | ~4 dk | aşama 1: düşen yıldırımlardan (uyarı halkalı) kaç, üç paratoner direğini Kaya ile çakarak toprağa göm; aşama 2: Statik havaya yükselir, Pervane + Balon ile yüzen bulutlardan ona ulaş, sırtındaki şaltere dokun; aşama 3: Mıknatıs ile Statik'in metal tacına çekil, tacın üstünde "Enerji ver" — Yetenek tuşu ile Bip'in anteninden Statik'e enerji akar → Statik sakinleşir, dördüncü Çekirdek Pil'i bırakır |

## Final
- Kapanış: dört pil jeneratörde, bütün ada aydınlanır; Statik pembe-mor dost bir buluta dönüşür ve robotların üstüne ılık yağmur yağdırır; Bip ile Pırıl jeneratörün tepesinde. Sonra **Emeği Geçenler** ekranı (asset sahipleri, CREDITS.md'den).
- Sonuç ekranı: tüm oyunun pil, vida ve süre toplamı.

## Numbers
| Ad | Değer | Birim |
|---|---|---|
| Bölüm süresi | ~17 [ASSUMPTION] | dk |
| Altın Vida | 2 (her alanda bir) | adet |

## Uygulama notları
- Üreticiler: `tools/level/ch4_d1_bulut_basamaklari.py`, `ch4_d2_kivilcim_kalesi.py`, `ch4_d3_patron.py`; patron `scripts/boss/static_boss.gd`, yıldırım `scripts/boss/lightning.gd`; final `scripts/story/closing.gd` (dördüncü bölümde) ve `scripts/ui/credits.gd`; testler `tests/ch4_test.tscn`, `tests/chapter_flow_test.tscn` (dört bölüm + final).
- Bilinen: Statik'in gövdesinde çarpışma yok (taç üstünde durulur); rüzgârlı Balon geçişlerinde ileriyi bırakıp yönlendirmek gerekir.

## History
- 2026-11-18: Patron aşamalarının başında ne yapılacağı yazıyla söylenir (patron betiğinde `PHASE_HINTS`); sıradaki hedefin ve gereken yeteneğin kaynağının üstünde sarı ok durur (`goal_nodes()`, `area.gd`). Geliştirici Paslı Kaptan 2. aşamada ne yapacağını bulamadı.
- 2026-11-18: tasarlandı.
- 2026-11-18: 2 alan, Statik ve final uygulandı.


## Görsel yenileme (2026-11-21)
Bulut zeminlerinin kenarlarında bulut kümeleri (KayKit Medieval bulutları). Bulut Basamakları'nda uzakta bulutların üstünde Kıvılcım Kalesi (kale + dört kule + bayrak, yön işareti). Kıvılcım Kalesi'nde iki yanda kuleler ve surlar, mancınık kulesi, bitişte bayraklar. Düşman görünüşü: Vidaböcek → sıçan, Zıpzıp → eşek arısı.
Bulut Basamakları uzatıldı (~70 m → ~130 m): dinlenme bulutundan sonra **Gökkuşağı Köprüsü** (renkli basamaklar, gidip gelen parça, eşek arısı), yanında süs gökkuşağı kemeri ve tepesinde gizli sandık (iki Yay sıçrayışı); **Balon Merdiveni** (sıcak hava balonlarına bağlı trambolinli bulutlar, 7,5 → 16 m); **Kale Manzarası** bitiş bulutu (kontrol noktası "manzara"; Kıvılcım Kalesi karşıda). Yeni gizli köşe: başlangıç bulutunun altındaki saklı bulut (trambolinle dönüş). Test: `tests/ch4_test.tscn`.
- **Patron arenası (2026-11-21):** çevresine temaya uygun manzara eklendi (çarpışmasız süsler; oynanış değişmedi).
Kıvılcım Kalesi: zeminler ve surlar taş (`castle` teması: kireçtaşı duvar, çatlak taş zemin), meşaleler, kırmızı sancaklar; yeni gizli köşe: avludaki köşe kulesinin metal levhalarıyla tepesine (Mıknatıs; 6 pil + sandık).

## Fırtına Köprüleri (yeni alan, 2026-11-21)
Bölüm 4'ün diğer bölümler gibi üç alanı olsun diye Yay Bahçesi yöntemiyle eklendi (Bulut Basamakları ile Kıvılcım Kalesi arasında). Üretici: `tools/level/ch4_d1b_firtina_kopruleri.py`, sahne `scenes/chapter4/d1b_firtina_kopruleri.tscn`, kimlik `ch4_kopru`.

**Yeni mekanik: yan rüzgâr.** `wind` alanının yatay kuvveti artık yerdeki Bip'i de iter (`bip.gd` `_wind_push`: yerde biriken itiş, sürtünmeye takılmaz, en çok 6 m/s, rüzgâr dinince söner). Kaya rüzgârdan etkilenmez (eski kural). Köprüde iki rüzgâr ters yönlerde 3 sn'lik ritimle eser; parçacıklar estiğini gösterir.

| # | Bölüm | Ne yapılır |
|---|---|---|
| 0 | Giriş Bulutu | Kaya kopyalanır |
| 1 | Rüzgârlı Köprü (öğret) | 22 m'lik dar köprü, yan rüzgâr; Kaya ile dayan ya da rüzgârın dinmesini bekle |
| 2 | Pervane Kulesi | 6,5 m'lik kule (Pervane), kontrol noktası "kopru1" |
| 3 | Mıknatıs Zinciri | fırtına boşluğunda üç asılı blok + tutamak, kontrol noktası "zincir" |
| 4 | Yan Rüzgârda Süzülüş (şaşırt) | 12 m Balon süzülüşü, rüzgâr doğuya sürükler; iniş kulesi doğuya doğru geniş, "ruzgar2" |
| 5 | Fırtına Kulesi (ustalık) | Yay ile üç 4,5 m'lik basamak, bitiş; uzakta Kıvılcım Kalesi |

**Gizli köşeler (3):** köprünün altındaki çıkıntı (rüzgâr seni oraya atabilir; trambolinle dön; 11 pil), paratoner tablası (P2'nin doğusu, Pervane; **Altın Vida**), Fırtına Gözü sütunu (bitiş kulesinin doğusu, Yay; 10 pil).

**Test:** `tests/ch4_test.tscn` (Kaya ile köprü, kayasız itilme, çıkıntıdan dönüş, Pervane, Altın Vida, Mıknatıs zinciri, rüzgârda süzülüş, Yay basamakları, gizli sütun).
