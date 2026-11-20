# Bölüm 2: Fırtına Limanı

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Statik, ikinci Çekirdek Pili adanın limanına götürdü. Liman rüzgârlı, gemiler ve vinçlerle dolu; fırtına bulutlarının arasında sallanan rıhtımlar var. Bölümün yeni oyuncağı **Pervane**: rüzgâr gülünden kopyalanan pervaneli şapka. Önceki dört yetenek de geri döner; her alan yeni bir yeteneği eski bir yetenekle birleştirir. Ritim Bölüm 1 ile aynı: **öğret → sına → şaşırt → ustalık**.

## Yeni yetenek: Pervane
| | |
|---|---|
| Kaynak nesne | rüzgâr gülü / pervaneli şapka |
| Pasif | — |
| Zıplama basılı (havada) | yükselme: 4,5 m/s, 1,2 sn yakıt; yere inince dolar |
| Yetenek tuşu (havada) | ileri atılma: 0,25 sn boyunca 11 m/s, her zıplamada bir kez |
| Balon'dan farkı | Balon yavaşça alçalır ve uzağa süzülür; Pervane kısa süre yukarı çıkar ve hızla ileri atılır |

## Alanlar
| # | Alan | Süre | Öğret | Sına | Şaşırt | Ustalık |
|---|---|---|---|---|---|---|
| 1 | Liman Rıhtımı | ~6 dk | Pervane ile yüksek rıhtımlara çıkmak | sallanan iskeleler, deniz üstünde atılmalar | Pervane ile bir martı sürüsünün (Zıpzıp) üstünden atılıp dalgaların arasında kaybolan platformlara inmek | uzun deniz geçişi: yükselme + atılma + yeniden yükselme |
| 2 | Fener Kulesi | ~6 dk | Fenerin içinde dikey tırmanış (Pervane + Yay) | dönen merdiven platformları | rüzgâr akımları Pervane ile yükselen Bip'i daha da yukarı taşır | fenerin tepesine çıkan dönen platform kulesi |
| 3 | Gemi Mezarlığı | ~7 dk | Mıknatıs ile batık gemilerin metal gövdelerine yapışmak | Kaya ile güvertedeki çatlakları kırıp ambarlara inmek | suyun altındaki yol (Kaya ile batma) | dört yetenek + Pervane'nin sırayla gerektiği parkur |
| 4 | Patron: Paslı Kaptan | ~4 dk | — | aşama 1: dev çapa sallanır, Pervane ile atılarak kaç; gemi direğindeki halatlara Pervane ile çık | aşama 2: güverteye düşen fıçıları Kaya ile ezerek kaptanın kalkanını indir | aşama 3: Mıknatıs ile kaptanın metal şapkasına çekil, tepeden Kaya ile çakıl → Çekirdek Pil |

Her alanda bir Altın Vida (bölümde 3).

## Patron: Paslı Kaptan
Görünüş: fanusunda bir balığın yüzdüğü dört bacaklı robot (Pixabay modeli, geliştiricinin seçimi; bkz. hikaye "Karakterlerin görünüşü"). Tepesinde metal kaptan şapkası, önünde üç can ışığı, güvertede dönen çapa kolu. Gemi güvertesi arenası, etrafı deniz.

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Pervane yükselme hızı | 4,5 [ASSUMPTION] | m/s | |
| Pervane yakıtı | 1,2 [ASSUMPTION] | s | tam yakıtla toplam yükseklik ~7,5 m (ölçüldü 7,8) |
| Pervane atılma hızı / süresi | 11 / 0,25 [ASSUMPTION] | m/s / s | ~3 m ileri (ölçüldü) |
| Bölüm süresi | ~25 [ASSUMPTION] | dk | |

## Uygulama notları
- Üreticiler: `tools/level/ch2_b1_rihtim.py`, `ch2_b2_fener.py`, `ch2_b3_gemi_mezarligi.py`, `ch2_b4_patron.py`; patron `scripts/boss/captain_boss.gd`; test `tests/ch2_test.tscn` (her alanın anahtar geçişleri + patronun 3 aşaması).
- Pervane yukarı rüzgârın içinde yakıt harcamaz ve daha hızlı yükselir (Fener Kulesi galerisi).
- Liman Rıhtımı'nda deniz geçişleri ~5,5 m'ye indirildi (gerekli boşluk ≈ %70 kuralı); Altın Vida adanın yanında havada asılı tablada.
- Gemi Mezarlığı'nda Mıknatıs zinciri alçak metal direklerle: yapış → zıpla = üstüne tırman → Yetenek = sıradakine çekil.
- Genel kural (kopyalama): taşınan yetenekle aynı kaynağın yanında Yetenek tuşu yeteneği kullanır (ör. şapkadaki Kaya kaynağının yanında çakılma).

## History
- 2026-11-18: Patron aşamalarının başında ne yapılacağı yazıyla söylenir (patron betiğinde `PHASE_HINTS`); sıradaki hedefin ve gereken yeteneğin kaynağının üstünde sarı ok durur (`goal_nodes()`, `area.gd`). Geliştirici Paslı Kaptan 2. aşamada ne yapacağını bulamadı.
- 2026-11-18: tasarlandı ve Pervane yeteneği uygulandı.
- 2026-11-18: 3 alan ve Paslı Kaptan uygulandı.


## Görsel yenileme (2026-11-21)
- **Liman Rıhtımı:** batıda kıyı kasabası (KayKit Medieval Hexagon evleri, han, pazar, su ve yel değirmeni, ağaçlar, uzak dağlar), rıhtımda varil/kasa/çuval/palet, suya inen ahşap kazıklar, sudan sıçrayan yunuslar ve uzakta yüzen balina (Quaternius Animated Fish; `prop` kind=dolphin/whale), yön işareti olarak uzakta kırmızı Fener adası. Yeni gizli köşe: iskelenin doğusundaki **direk tepesi** (Pervane ile; 11 pil). Test: `tests/ch2_test.tscn`.
- **Fener Kulesi:** adanın çevresinde kumsal halkası ve iri kayalar, iki balıkçı evi (çarpışmalı), varil/kasa/çuval, fenerin dibinde gerçek kapı ve kırmızı şeritlerde pencereler, tepede bayrak, çevrede yunuslar ve balina.
