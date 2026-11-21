# Kostümler (Bip'in renkleri)

Oyuncunun topladığı pillerle açılan renk kostümleri. Toplamanın bir ödülü olsun, oyuncu Bip'i kendine benzetebilsin diye (Astro Bot'taki kostüm odası gibi). Atölye'deki **Kostüm Dolabı**'ndan (kuzey duvarı, pencerenin sağı) ya da hızlı menüdeki "Kostümler" düğmesinden seçilir.

**Görünüş (2026-11-21):** Kostüm Dolabı ve Koleksiyon ekranında her kostüm minik, yavaşça dönen bir 3B Bip olarak kartta durur (`scripts/ui/skin_cards.gd`, her kart kendi küçük SubViewport'unda). Seçili kart yeşil, üstündeki Bip el sallar; kilitli kostümler karanlık siluet ve gereken pil/vida sayısıyla görünür. Karta dokunmak kostümü seçer, Atölye'deki Bip anında değişir.

## Rules
1. Kostüm yalnızca görünüştür; oynanışı değiştirmez.
2. Kostüm oyuncunundur, kayıt yuvasının değil: Ayarlar dosyasında tutulur (`Settings.skin`).
3. Kilit, kayıt yuvalarındaki en iyi ilerlemeye bakar (en çok pil ya da Altın Vida).
4. Taşınan yetenek kostümün üstüne hafif renk verir (kopyalama kural 4 korunur).
5. Gri metal parçalar ve gözler kostümden etkilenmez; yalnızca boyalı gövde renk değiştirir.

## Numbers
| Kostüm | Ton kaydırma | Kilit | Not |
|---|---|---|---|
| Klasik Sarı | 0 | açık | |
| Gökyüzü | +0,45 | 60 pil | |
| Nane | +0,22 | 150 pil | |
| Pamuk Şeker | +0,78 | 250 pil | |
| Lav | −0,11 | 400 pil | |
| Gece | +0,6 (soluk, koyu) | 600 pil | |
| Altın | −0,02 (parlak, hafif ışıltı) | 10 Altın Vida | |

## Uygulama
- Liste: `GameState.SKINS`; kilit: `GameState.skin_unlocked()`.
- Gölgelendirici: `assets/shaders/bip_skin.gdshader` (HSV ton kaydırma, yalnızca doygun piksellerde); `bip_visuals.gd` `apply_skin()`, `Settings.changed` ile anında güncellenir.
- Dolap: `menu_object.gd` kind `wardrobe` (KayKit dolap + boya kutuları), `hub.gd` `_open_wardrobe()`.

## History
- 2026-11-21: ilk sürüm, 7 kostüm.

## Şapkalar (2026-11-22)
Renk kostümlerinden ayrı, başa takılan parçalar. **Yıldızla** açılır (herhangi bir kayıt yuvasındaki en çok toplam yıldız), Kostüm Dolabı'ndaki "Şapka" satırından seçilir. Basit şekillerden kurulur (`scripts/player/hat_models.gd`), başın tepesindeki kemiğe bağlıdır, kafayla birlikte sallanır.

| Şapka | Gereken yıldız | Not |
|---|---|---|
| Şapka yok | 0 | |
| Parti Şapkası | 5 | |
| Pervaneli Şapka | 12 | pervanesi koşu hızıyla döner |
| Silindir Şapka | 20 | |
| Taç | 35 | |

Kod: `GameState.HATS`, `hat_unlocked`, `best_stars`; `Settings.hat`; `bip_visuals.apply_hat`. Kostüm kartlarındaki minik Bip'lerde şapka görünmez (açık konu).

