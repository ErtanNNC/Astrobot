# Arayüz görünüşü

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Geliştirici: "UI hâlâ çok basic, daha güzel ve keyifli olmalı." Menüler, HUD ve dokunmatik butonlar Astro Bot'taki gibi neşeli, tok ve dokunduğunda tepki veren bir görünüme geçti. Tek yer: `scripts/ui/ui_kit.gd` (`UIKit`); tema oyun açılırken kök pencereye uygulanır (`Settings._ready`).

## Rules
1. **Yazı tipi:** Nunito (ağırlık 900, yuvarlak, tüm Türkçe harfler). Tüm yazılar beyaz, lacivert dış çizgili ve hafif gölgeli; büyük başlıklar sarı. (Fredoka denendi: "ş", "ğ", "İ" harfleri yok, elendi.)
2. **Butonlar:** Kenney UI Pack'in derinlikli butonları. Basılınca derinlik kaybolur ve buton aşağı iner; üstüne gelince/odakta hafif büyür, basınca ezilir. Yazısına göre otomatik simge alır (Devam ▶, Ayarlar ⚙, Atölye ⌂ ...).
3. **Renk anlamı:** yeşil = devam/onay, mavi = normal, kırmızı = çıkış/sil, mor = Atölye'ye dön, gri = kapalı ayar, sarı = Atölye'deki hızlı menü.
4. **Kartlar:** koyu mavi yuvarlak kart, açık mavi kalın kenar, alt kenar daha kalın (tok görünüm), gölgeli. Açılırken küçükten büyüyerek "zıplar".
5. **HUD:** kalpler ve pil sayacı yarı saydam hap zeminlerde; dolu kalpler hafifçe "nefes alır" ve parlar; pil alınınca sayaç büyür ve arkasında yeşil halka açılır. Alan adı yazısı yaylanarak büyür; alt yazı yuvarlak zeminde.
6. **Dokunmatik butonlar:** Zıpla (mavi), Yetenek (yeteneğin rengiyle boyanan), Vuruş (kırmızı) Kenney yuvarlak butonları; basılıyken içeri gömülür. Yerleşim değişmedi ([mobil kontroller](../mobil-kontroller/design.md)).
7. **Sonuç ekranı:** gökyüzü renginde degrade zemin, düşen konfeti, simgeli istatistik kartları; sayılar sıfırdan sayarak gelir.
8. **Başlık ekranı:** BİP logosu hafifçe sallanır, alt yazı süzülür, "Başlamak için dokun" nabız gibi atar.

## Numbers
| Ad | Değer | Birim |
|---|---|---|
| Buton yüksekliği | 80 | px |
| Buton yazısı | 30 | px |
| Buton simgesi | 40 | px |
| Kart köşe yarıçapı | 36 | px |
| Basınca ölçek / üstüne gelince | 0,94 / 1,04 | × |
| Kart açılış süresi | 0,32 | s |

## Kaynaklar
Kenney UI Pack ve Game Icons (CC0, OpenGameArt), Nunito (SIL OFL 1.1, Google Fonts deposu). Ayrıntı: `CREDITS.md`.

## History
- 2026-11-18: oluşturuldu ve uygulandı.
