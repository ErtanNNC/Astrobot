# Kostümler (Bip'in renkleri)

Oyuncunun topladığı pillerle açılan renk kostümleri. Toplamanın bir ödülü olsun, oyuncu Bip'i kendine benzetebilsin diye (Astro Bot'taki kostüm odası gibi). Atölye'deki **Kostüm Dolabı**'ndan (kuzey duvarı, pencerenin sağı) ya da hızlı menüdeki "Kostümler" düğmesinden seçilir.

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
