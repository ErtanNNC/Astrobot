# Geri dönme sebepleri (yıldız, rekor, günlük görev, izler)

Durum: oyunda (2026-11-21). Kod: `scripts/autoload/game_state.gd` (yıldız, rekor, izler), `scripts/autoload/daily.gd`
(günlük görev), `scripts/level/area.gd` (süre sayacı), `scripts/ui/hub.gd` (Alan Seç, Kostüm Dolabı, hızlı menü).

## Amaç
Oyunu bitiren ya da bir alanı geçen oyuncunun aynı alana dönmek için bir sebebi olsun; her gün açınca küçük bir hedef bulsun.

## Kurallar
1. **Yıldızlar:** her alan en çok 3 yıldız verir.
   - 1. yıldız: alanı bitir.
   - 2. yıldız: alandaki pillerin %80'ini toplamış ol (önceki turlarda toplananlar da sayılır; pili olmayan alanda kendiliğinden gelir).
   - 3. yıldız: alanı hedef sürenin altında bitir.
2. **Süre:** alana baştan girince sıfırlanır, kontrol noktasıyla birlikte kaydedilir, duraklatınca ve ara sahnede durur. Ölmek süreyi sıfırlamaz.
3. **Rekor:** her alanın en iyi süresi ve en çok yıldızı kayıt yuvasında tutulur. Kötü bir tur rekoru bozmaz. Rekor kırılınca alan sonunda "Yeni rekor!" yazar.
4. **Nerede görünür:** alan sonu afişinde (pil, süre, yıldız) ve Alan Seç listesinde her alanın yanında.
5. **Günlük görev:** her gün havuzdan sırayla bir görev gelir. Bitirince 15 bonus pil kazanılır ve seri 1 artar. Bir gün kaçırılırsa seri sıfırlanır. Görev Atölye'nin hızlı menüsünde yazar; bitince oyun içinde afiş çıkar.
6. **Bonus pil** kostüm ve iz açmaya sayılır; alanlardaki pil sayacını değiştirmez. Oyuncuya aittir (kayıt yuvasına değil).
7. **Koşu izleri:** Bip koşarken arkasında renkli zerreler bırakır. Pille açılır, Kostüm Dolabı'ndan seçilir.

## Sayılar
| Ad | Değer | Birim | Not |
|---|---|---|---|
| İkinci yıldız için pil oranı | 80 | % | |
| Hedef süre | 25 + 0,8 × yol uzunluğu (m), 5'e yuvarlı | s | [ASSUMPTION]; telefonda oynanıp ayarlanmalı. Tablo: `GameState.AREA_PAR` |
| Patron alanı hedef süresi | 180 | s | [ASSUMPTION] |
| Günlük görev ödülü | 15 | pil | |
| Görev: pil topla | 40 | pil | tekrar toplanan (silik) piller de sayılır |
| Görev: düşman yen | 8 | düşman | |
| Görev: alan bitir | 2 | alan | |
| Görev: yıldızla bitir | 3 | yıldız | |
| İzler | Kıvılcım 100, Buz Tozu 200, Şeker Pembe 350, Gökkuşağı 500 | pil | |

## Kenar durumları
- Oyuncu alana kayıttan, ortadaki bir kontrol noktasından dönerse süre kaldığı yerden devam eder.
- Saat geri alınırsa gün numarası değişir, görev yeniden kurulur ve seri sıfırlanır (hile kazandırmaz).
- Eski kayıtlarda `best` alanı yoktur; ilk bitirişte oluşur.

## Testler
`tests/replay_test.tscn`: yıldız hesabı, rekor, günlük görev (ilerleme, ödül, tek ödül, seri), iz kilidi.

## Açık konular
- Hedef süreler ölçülmedi; ilk oyun testinde her alan için gerçek "iyi tur" süresi alınmalı.
- Yazı tipinde yıldız işareti yok; şimdilik "2/3 yıldız" diye yazıyla gösteriliyor. Simgeyle göstermek daha iyi olur.
