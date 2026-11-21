# Bölüm 5: Gizli Adalar (bonus)

Final (Statik) bittikten sonra açılan bonus bölüm. Hikâyeye bağlı değildir; patron yoktur. Altı yeteneğin hepsini yeni ortamlarda, karışık ve oyuncak gibi eğlenceli biçimde kullandırır. Final kapanışı bittiğinde kayıt bu bölümün ilk alanına geçer (`closing.gd`), Atölye kapısı oradan devam eder. Son alanın çıkışı bölüm sonuç ekranına gider.

## Alanlar
| # | Alan | Süre | Öğret | Sına | Şaşırt | Ustalık |
|---|---|---|---|---|---|---|
| 1 | Oyuncak Kasabası | ~6 dk | Yay ile dev hediye kutuları (4 m) | oyuncak tren (hareketli vagon) | Balon ile kaleye süzülüş | Mıknatıs levhalarıyla kule, Pervane ile Fındıkkıran'ın şapkası |
| 3 | Volkan Adası | ~6 dk | **lav**: Buz ile lavın üstünde yürümek | düşen bazalt taşları | gayzerlerde Balon ile yükselmek | magma zinciri (Mıknatıs), krater kenarı (Pervane) |
| 4 | Şampiyon Yolu | ~5 dk | — | altı yetenek art arda | — | Dev Yay ile altın kupa platformu |
| 2 | Yıldız Gözlemevi | ~6 dk | Buz ile gölün üstünde yürümek | Kaya ile cam zemini kırıp tünelden geçmek | dönen yıldız platformları (Yay) | teleskop rüzgârında Balon ile kubbeye |

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

## Yıldız Gözlemevi (2026-11-21)
Üretici: `tools/level/ch5_e2_yildiz_gozlemevi.py`, kimlik `ch5_gozlemevi`. Gece; gökte ay kayaları, parlayan yıldızlar (KayKit yıldızları), fenerler. Yön işareti: sonda kubbeli **gözlemevi** ve dev teleskop. (Gece göğünde ufkun altı da koyu: `lvl.py` gökyüzüne `ground` rengi eklendi.)

| # | Bölüm | Ne yapılır |
|---|---|---|
| 0 | Ay Kayası | Buz kopyalanır |
| 1 | Yıldız Gölü | Buz ile suyun üstünde yürü, 2,15 m'lik kıyıya zıpla (yüzerek çıkılmaz); kontrol noktası "gol" |
| 2 | Meteor Çukuru | Kaya ile cam zemini kır, tünelden geç, trambolinle çık; "meteor" |
| 3 | Takımyıldız | üç dönen yıldız platformu, Yay ile 4 m'lik basamaklar; "takimyildiz" |
| 4 | Teleskop Rüzgârı | Balon ile rüzgârda yüksel, kubbe terasına süzül; bitiş |

**Gizli köşeler (3):** göldeki adacık (Buz ile; 10 pil), tünelin doğu duvarındaki oyuk (**Altın Vida**), kayan yıldız tablası (C kıyısının doğusundaki trambolinden; 10 pil).

## Volkan Adası (2026-11-21)
Üretici: `tools/level/ch5_e3_volkan_adasi.py`, kimlik `ch5_volkan`. **Yeni öğe: lav** (`water_zone.gd` `lava = true`): turuncu yüzey, değen yanar ve son kontrol noktasına döner (1,5 sn bekleme, art arda can gitmez); Buz taşıyan Bip'in ayağının altında lav soğuyup gri **bazalt karolara** döner (suda olduğu gibi). Lav yüzeyi kıyıyla aynı yükseklikte (karodan kıyıya adım yok). Yön işareti: sonda katmanlı dev volkan ve dumanı.

| # | Bölüm | Ne yapılır |
|---|---|---|
| 0 | Kara Kumsal | Buz kopyalanır |
| 1 | Lav Nehri | Buz ile 18 m'lik lavın üstünde yürü; kontrol noktası "nehir" |
| 2 | Bazalt Basamakları | lavın üstünde üç düşen taş; "bazalt" |
| 3 | Gayzerler | sıcak hava akımında Balon ile 8 m'lik platoya; "gayzer" |
| 4 | Magma Zinciri | lavın üstünde üç metal blok + tutamak (Mıknatıs); "zincir" |
| 5 | Krater Kenarı | Pervane ile 6,5 m, bitiş |

**Gizli köşeler (3):** nehirdeki adacık (Buz; 10 pil), ikinci gayzerin tepesindeki çıkıntı (Balon; 10 pil), krater kenarındaki niş (Pervane; **Altın Vida**).

## Şampiyon Yolu (2026-11-21)
Üretici: `tools/level/ch5_e4_sampiyon_yolu.py`, kimlik `ch5_sampiyon`. Bonus bölümün ve oyunun en zor parkuru (Mario'daki "Şampiyon Yolu" fikri). Ölçüler oyunda zaten test edilmiş bölümlerden alındı: Yay ile iki 4 m'lik teras → 12,5 m Balon süzülüşü (kontrol noktası "sampiyon1") → 5,5 m aralıklı Mıknatıs zinciri → Kaya ile cam zemin, tünel, trambolin ("sampiyon2") → Buz ile havuz ve 2,15 m kıyı → Pervane ile 6,5 m ("sampiyon3") → **Dev Yay** ile altın kupa platformu (bitiş). Gökkuşağı yayı, sıcak hava balonları.

**Gizli köşe:** P1'in doğusunda aşağıdaki adacıkta **Altın Vida** (Balon ile in, trambolinle dön).

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
`tests/ch5_test.tscn`: Oyuncak Kasabası (üç kutu, Altın Vida sütunu, tren, Balon, Mıknatıs, Pervane, iki gizli köşeden dönüş); Yıldız Gözlemevi (Buz ile göl, adacık, Kaya ile cam zemin ve tünel, oyuk, yıldız tablası, teleskop rüzgârı).

## History
- 2026-11-21: bölüm ve ilk alan (Oyuncak Kasabası) eklendi; ikinci alan Yıldız Gözlemevi, üçüncü alan Volkan Adası, dördüncü alan Şampiyon Yolu eklendi.
