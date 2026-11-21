# Arayüz görünüşü

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Geliştirici: "UI hâlâ çok basic, daha güzel ve keyifli olmalı", sonra "itch.io'dan daha smooth bir tasarım kullan". Menüler, HUD ve dokunmatik butonlar pzUH'un "Free Game GUI" paketine (itch.io, CC0) geçti: krem pencereler, kırmızı kurdeleli başlıklar, parlak jöle butonlar, yıldızlar. Tek yer: `scripts/ui/ui_kit.gd` (`UIKit`); tema oyun açılırken kök pencereye uygulanır (`Settings._ready`).

## Rules
1. **Yazı tipi:** Nunito (ağırlık 900, yuvarlak, tüm Türkçe harfler). Tüm yazılar beyaz, lacivert dış çizgili ve hafif gölgeli; büyük başlıklar sarı. (Fredoka denendi: "ş", "ğ", "İ" harfleri yok, elendi.)
2. **Butonlar:** parlak jöle butonlar (mavi, yeşil, kırmızı, gri; mor = gri boyanmış). Basılınca koyulaşır ve yazı aşağı iner; üstüne gelince/odakta hafif büyür, basınca ezilir. Yazısına göre otomatik simge alır (Devam ▶, Ayarlar ⚙, Atölye ⌂ ...).
3. **Renk anlamı:** yeşil = devam/onay, mavi = normal, kırmızı = çıkış/sil, mor = Atölye'ye dön, gri = kapalı ayar, sarı = Atölye'deki hızlı menü.
4. **Pencereler:** krem renkli, beyaz kenarlı, köşesinde parlama kabarcıkları olan pencere; içindeki yazılar kahverengi. Büyük başlıklar kırmızı kurdele üstünde beyaz yazı. Açılırken küçükten büyüyerek "zıplar".
5. **HUD:** kalpler ve pil sayacı krem renkli, beyaz kenarlı hap zeminlerde; dolu kalpler hafifçe "nefes alır" ve parlar; pil alınınca sayaç büyür ve arkasında yeşil halka açılır. Alan adı yazısı yaylanarak büyür; alt yazı yuvarlak zeminde.
6. **Dokunmatik butonlar:** jöle kare butonlar: Zıpla (mavi, yukarı ok), Yetenek (yeteneğin rengiyle boyanan), Vuruş (kırmızı, dönen ok), Duraklat (mavi); basılıyken koyulaşıp aşağı iner. Yerleşim değişmedi ([mobil kontroller](../mobil-kontroller/design.md)).
7. **Sonuç ekranı:** gökyüzü renginde degrade zemin, düşen konfeti, 3 yıldız (1 + Altın Vidaların yarısı + hepsi), gömme kutularda simgeli istatistikler; sayılar sıfırdan sayarak gelir. Kaydırıcılar pembe dolgulu, tutamak yıldız.
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
pzUH Free Game GUI (CC0, itch.io; sprite'lar paketin büyük PNG sayfalarından otomatik kesildi → `assets/ui/pzuh/`), buton içi simgeler Kenney Game Icons (CC0), Nunito (SIL OFL 1.1). Ayrıntı: `CREDITS.md`.

## History
- 2026-11-18: Kenney butonları yerine pzUH Free Game GUI (daha yumuşak, şekerli görünüm).
- 2026-11-18: oluşturuldu ve uygulandı.
- 2026-11-21: Uzun pencereler (çok düğmeli hızlı menü, Alan Seç) kısa ekrana sığmıyordu; `UIKit.pop_in` artık gerekirse pencereyi küçültüp ortalar.
