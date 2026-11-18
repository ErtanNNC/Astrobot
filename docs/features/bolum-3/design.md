# Bölüm 3: Buzul Tepesi

**Status:** in progress · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Üçüncü Çekirdek Pil, adanın karlı dağına düştü ve dağı dondurdu. Bölümün yeni oyuncağı **Buz**: buz kristalinden kopyalanır. Buzlu dünyada her şey kayar, sular donar, düşmanlar platforma dönüşür. "Tek yetenek, bin kullanım" burada en çok görünür: aynı Buz hem yol yapar hem düşmanı merdivene çevirir.

## Yeni yetenek: Buz
| | |
|---|---|
| Kaynak nesne | buz kristali |
| Pasif | suyun üstünde yürür: ayağının altında 2 m'lik buz karoları belirir, 6 sn sonra erir |
| Yetenek tuşu | 3,5 m içindeki en yakın düşmanı dondurur: 8 sn boyunca buz kütlesi olur, üstüne çıkılır, zarar vermez |

## Alanlar
| # | Alan | Süre | Öğret | Sına | Şaşırt | Ustalık |
|---|---|---|---|---|---|---|
| 1 | Buz Mağarası | ~6 dk | Buz ile su birikintilerinin üstünde yürümek | eriyen karolarla uzun su geçişleri | dondurulan düşmanı basamak yapıp yüksek çıkıntıya ulaşmak | düşman sürüsünü sırayla dondurup merdiven yapmak |
| 2 | Donmuş Göl | ~6 dk | gölün üstünde Buz ile yol açmak; Balon ile göl üstü süzülme | kaybolan buz kütleleri, rüzgârlı geçitler | Kaya ile buzu kırıp göl altındaki yolu bulmak | Buz + Pervane ile uzun göl geçişi |
| 3 | Kar Zirvesi | ~7 dk | Yay ile kar tepelerinde yüksek zıplamalar | Mıknatıs ile teleferik direklerine tırmanmak | çığ: arkadan gelen kayalardan kaçış (hareketli tehlikeler) | altı yeteneğin hepsini isteyen zirve parkuru |
| 4 | Patron: Kardan Dev | ~4 dk | — | aşama 1: dev kartopu atar; düşmanları (Zıpzıp) dondurup merdiven yapıp devin omzuna çık | aşama 2: gölün ortasındaki dev adasına Buz ile yürü, şalteri indir | aşama 3: Pervane ile devin başının üstüne yüksel, Kaya ile çakıl → Çekirdek Pil |

Her alanda bir Altın Vida (bölümde 3). Bölüm sonunda üç Çekirdek Pil yerinde; dördüncüsü için Statik'in kendisiyle buluşma (Bölüm 4, later).

## Patron: Kardan Dev
Hazır model yok: üst üste üç kar topu (küre), kayadan kollar (Quaternius kayaları), havuç burun, kömür gözler, başında buz tacı. Donmuş göl arenası.

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Buz dondurma menzili | 3,5 [ASSUMPTION] | m | |
| Donma süresi | 8 [ASSUMPTION] | s | |
| Buz karosu ömrü | 6 [ASSUMPTION] | s | su geçişinde geri dönmeye yetiyor mu |

## History
- 2026-11-18: tasarlandı ve Buz yeteneği uygulandı.
