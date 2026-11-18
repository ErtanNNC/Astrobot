# Hikaye

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Hikaye sade, sıcak ve tamamen sözsüzdür: kısa sahneler, pandomim, müzik ve simgelerle anlatılır, bu yüzden her yaşta ve her dilde anlaşılır. Amaç oyuncuya "neden zıplıyorum?" sorusuna sevimli bir cevap vermek ve Bip'i sevdirmektir; oynanışı hiçbir zaman uzun süre durdurmaz.

## Dünya ve karakterler
- **Dişli Adası:** robotların yaşadığı, her şeyin yay, balon, mıknatıs ve dişlilerle çalıştığı neşeli bir ada. Adanın ortasındaki **Ana Jeneratör**, dört **Çekirdek Pil** ile bütün adaya enerji verir.
- **Bip:** atölyenin en küçük, en çok gözden kaçan tamir robotu. Anteni hep biraz eğri durur. Meraklı, cesur, biraz sakar.
- **Pırıl:** atölyenin ateş böceğine benzeyen minik lamba-drone'u. Bip'in rehberi; konuşmaz, ışığıyla yol gösterir ve gerektiğinde başının üstünde tuş simgeleri belirir (bkz. [Bölüm 1](../bolum-1/design.md) öğretici).
- **Statik:** fırtınadan doğan, mor kıvılcımlı yaramaz bir bulut. Kötü değil, aç: enerjiyi seviyor. Çekirdek Pilleri yutup adanın dört bir yanına saçtı ve dokunduğu eski makineleri huysuz hale getirdi.

## Karakterlerin görünüşü (asset karşılıkları)
Karakterler bulunabilen CC0 asset'lerle yapılır; tarif asset'e uyarlanır (D-010). Asset ayrıntıları ve lisanslar: `CREDITS.md`.

| Karakter | Asset | Uyarlama | Durum |
|---|---|---|---|
| **Bip** | Quaternius "Animated Robot" (turuncu, iri elli, gözlüklü robot; 14 animasyon) | kafasına parlayan bir anten eklendi; "eğri anten" için anten hafif yana yatırılabilir; taşınan yetenek gövde rengini değiştirir (M2) | oyunda |
| **Pırıl** | Quaternius Ultimate Platformer Pack "Bee" (uçma animasyonlu böcek) | sarı-beyaz parlayan malzeme ve küçük ışık; "ateş böceği lamba-drone" olarak boyanır | oyunda (`scripts/npc/piril.gd`) |
| **Statik** | Quaternius "Cloud" modelleri | mora boyanır, etrafında kıvılcım parçacıkları, yavaşça süzülür ve sallanır | oyunda (açılış, kapanış, uzak manzara) |
| **Vidaböcek** (ilk düşman) | Quaternius Ultimate Platformer Pack "Crab" (yürüme, ölüm, isabet animasyonları) | özgün kırmızı rengi kaldı (tehlike rengi, sanat yönü); adı "Vidaböcek" | oyunda |
| **Zıpzıp** (zıplayan düşman) | Quaternius "Skull" | yerinde zıplar, Bip yaklaşınca ona doğru seker | oyunda |
| **Hurda Goblin** (kovalayan düşman) | Quaternius "Enemy" (boynuzlu yeşil) | Bip'i görünce kovalar, uzaklaşınca evine döner | oyunda |
| **Hurdacı Vinç** (patron) | uygun hazır model bulunamadı | basit şekillerden kuruldu: turuncu kule, dönen bom, kırmızı gözlü kabin, kancada Çekirdek Pil, 3 can ışığı (`scripts/boss/crane_boss.gd`) | oyunda |
| **Atölye robotları** (kapanışta alkışlayanlar) | Quaternius "Animated Robot" | farklı renklere boyanmış kopyalar; "Wave", "Yes", "Dance" animasyonları | oyunda (kapanış) |

## Ana hikaye (tüm oyun)
1. Bir fırtına gecesi Statik Ana Jeneratör'e çarpar, dört Çekirdek Pili kapar ve adaya dağıtır; ada karanlığa gömülür.
2. Atölyede şarj istasyonunda uyuyan Bip'in eğri antenine bir yıldırım düşer. Bip uyanır; anteni artık dokunduğu nesnenin yeteneğini kopyalayabilmektedir.
3. Bip ve Pırıl her bölümde bir Çekirdek Pili geri alır. Her pil yerine takıldığında adanın bir bölgesi yeniden aydınlanır.
4. Son bölümde (Bölüm 4) Statik yenilmez, ikna edilir: Bip ona anteninden enerji verir, Statik adanın dost fırtınası olur (D-014). Final sahnesinde pembe bir buluta dönüşüp robotların üstüne ılık yağmur yağdırır; ardından Emeği Geçenler.

## Bölüm 1: "Uyanış"
**Bölge:** Tamirhane Vadisi. **Hedef:** Hurdacı Vinç'in yuttuğu ilk Çekirdek Pil.

| Sahne | Ne zaman | Süre | İçerik |
|---|---|---|---|
| Açılış | Yeni Oyun | ~45 s, atlanabilir | Fırtına, Statik pilleri kapar, ada kararır; atölyede yıldırım Bip'in antenine düşer, Bip'in gözleri yanar. Oynanış doğrudan Bip'in uyandığı yerden başlar. |
| Pırıl ile tanışma | öğreticinin başı | ~10 s, oynanış içinde | Pırıl Bip'in kafasına konar, onu dürter, kapıya doğru uçar. Kamera kesilmez. |
| Vadi manzarası | atölye kapısı açılınca | ~8 s, oynanış içinde | Kamera vadiyi ve uzakta karanlık jeneratör kulesini gösterir; Statik'in kıvılcımları kulenin etrafında. Yön işareti olur. |
| Statik'in ilk görünüşü | Kaya Ocağı girişi | ~10 s | Statik bir kıvılcımla Hurdacı Vinç'i "uyandırır" ve kaçar. Patronun gelişini haber verir. |
| Patron girişi | patron alanı | ~8 s, atlanabilir | Vinç, kancasında ışıldayan Çekirdek Pil ile ayağa kalkar. |
| Kapanış | patron yenilince | ~40 s, atlanabilir | Bip pili jeneratöre takar, vadi aydınlanır, robotlar dışarı çıkıp Bip'i alkışlar; Statik uzakta bir sonraki bölgeye kaçar (Bölüm 2 merakı). Sonuç ekranına geçer. |

## Rules
1. Hiçbir sahnede yazılı diyalog yoktur; bölüm adı ve sonuç ekranı dışında metin kullanılmaz.
2. Tüm ara sahneler atlanabilir; ilk izlemede de. Atlama tuşu basılı tutulur (yanlışlıkla atlamayı önler).
3. Oynanışın ortasındaki kısa anlar (10 saniyeden kısa) kontrolü elden almaz ya da en fazla 10 saniye alır.
4. İzlenen sahneler Atölye'deki televizyondan tekrar izlenebilir ([ana menü](../ana-menu/design.md)).

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Atlamak için basılı tutma | 1,0 [ASSUMPTION] | s | |
| En uzun ara sahne | 45 [ASSUMPTION] | s | çocuklar sıkılıyor mu |
| Oynanış içi an, en uzun | 10 | s | |

## Open questions
- [ASSUMPTION] Statik'in sonda dost olması; ton olarak "kötü adam yenilir" yerine seçildi, değiştirilebilir.
- Karakter isimleri (Bip, Pırıl, Statik, Hurdacı Vinç) geçici; İngilizce sürüm için karşılıkları gerekecek.

## History
- 2026-11-18: tasarlandı.
- 2026-11-18: karakterlerin asset karşılıkları eklendi (D-010).
- 2026-11-18: açılış (`scripts/story/opening.gd`) ve kapanış (`scripts/story/closing.gd`) sahneleri uygulandı; basılı tutarak atlanır. Ara sahnelerin TV'den tekrar izlenmesi henüz yok.
