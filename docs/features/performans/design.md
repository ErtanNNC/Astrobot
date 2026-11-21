# Performans (telefon)

Hedef: orta sınıf Android telefonda 60 kare/sn (en az 30). Gerçek cihazda ölçülür: Ayarlar → **"Kare hızını göster"** ekranın üstünde anlık ve en düşük FPS'i yazar.

## Rules
1. Uzaktaki küçük nesneler çizilmez: `area.gd _optimize_rendering` (piller 50 m, küçük süs ve varlıklar 60 m, orta boy 85 m; 5 m'den büyükler ve MultiMesh süsler her mesafede görünür, yer işaretleri kaybolmaz).
2. 1,3 m'den küçük nesneler ve bulutlar gölge düşürmez.
3. Bip oyun içinde hafif modelle çizilir (`bip_mesh_lite.res`, ~12 bin üçgen / 14 bin köşe; özgün model 49 bin üçgen / 148 bin köşe). Üretici: `tests/make_bip_lod.gd`. Kostüm kartları ve simge yakın çekim olduğu için özgün modeli kullanır.
4. Doğal zeminlerin üstü zemin başına tek parça örtüdür (12 üçgen), karo karo değil.

## Numbers (2026-11-21, masaüstü ölçümü, alan başlangıcı; `tests/_perf2` geçici aracı)
| Alan | Çizim çağrısı önce → sonra | Üçgen önce → sonra |
|---|---|---|
| Yay Bahçesi | 389 → 260 | 342 bin → 60 bin |
| Balon Kanyonu | 572 → 379 | 402 bin → 96 bin |
| Gemi Mezarlığı | 662 → 451 | 222 bin → ~95 bin |

## History
- 2026-11-21: ilk performans turu (uzaklık gizleme, gölge azaltma, hafif Bip, tek parça zemin örtüsü, FPS göstergesi). Gerçek telefon ölçümü geliştiriciden bekleniyor.
