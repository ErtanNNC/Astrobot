# Oyun hissi (Astro Bot / Mario Odyssey karşılaştırması)

**Status:** in progress · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Geliştirici oyunu oynadı: "Astro Bot ya da Mario Odyssey'den farklı bir his var." Bu doküman iki oyunu hissi veren öğelere ayırır, Bip'te neyin eksik olduğunu yazar ve sırayla kapatır.

## Karşılaştırma
| Öğe | Astro Bot | Mario Odyssey | Bip (önce) | Bip (şimdi) |
|---|---|---|---|---|
| Havada kalma | Zıpla basılı: ayaklardan lazerli jetle kısa süzülme; lazer altındaki düşmanı vurur | Şapka atıp üstüne zıplama, dalış | Yok (yalnız Balon/Pervane) | **Jet süzülme** baştan açık |
| Vuruş | Yumruk + basılı tutunca dönme | Şapka atma, yere çakılma | Yalnız üstüne basma | Dönme (Vuruş butonu), hareketler dokümanı D-016 |
| Ek hareketler | Az; güç-yükleri bölüme göre | Çok: uzun atlama, duvar zıplaması, takla | Yoktu | Tutunma, atılma, duvar zıplaması, çift zıplama (D-016) |
| Toplanabilir | Yüzlerce para, yakından geçince Bip'e akar | Çok para, ay | Pil sayısı az, değmek gerekiyor | Pil yakından **kendiliğinden çekilir**; çalılardan pil çıkar |
| Canlı dünya | Her şey tepki verir: otlar eğilir, nesneler kırılır, para saçılır | Etkileşimli nesneler | Süsler cansız | Ot/çalı/bitki içinden geçince sallanır; dönmeyle vurulan çalı pil düşürür, ağaç sarsılır |
| Ceza | Tek vuruşta ölüm ama hemen kontrol noktasından devam, ceza yok | 3 can, para kaybı | Can biter → kontrol noktası, ceza yok | Aynı (zaten Astro gibi) |
| Kamera | Yola göre yönlendirilmiş, oyuncunun etrafında savrulmaz | Serbest, elle | Bip yana koşunca hızla arkasına dönüyordu | Kendiliğinden dönme yarıya indi (1,6 → 0,9) |
| Seviye yoğunluğu | Her adımda bir şey: süs, sır, robot, para dizisi | Açık alan, sık ay | Geniş boş zeminler | **Sıradaki iş** (aşağıda) |

## Rules
1. **Jet süzülme:** havada, yükselme bitince Zıpla basılı tutulursa Bip ayaklarındaki jetlerle asılı kalır (yavaş alçalır). Süre yerde, kenara tutununca ve duvar zıplamasında dolar. Balon, Pervane ve Kaya'da yoktur (onların kendi zıplama-basılı davranışı var). Jet ışınının altındaki düşman ve sandık kırılır.
2. **Pil çekimi:** pil Bip'e 1,6 m'den yakınsa kendiliğinden uçar (Mıknatıs yeteneğiyle 3,5 m).
3. **Canlı süsler:** ot, çalı ve bitkiler Bip içinden koşunca esner; dönme saldırısı çalı/bitkiyi sarsar ve her çalı bir kez pil düşürür; ağaçlar dönmeyle sarsılır.
4. **Kamera:** kendiliğinden arkaya dönme yavaşladı; kamera yolu izler, oyuncunun her yön değişiminde savrulmaz.

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Jet süzülme süresi | 0,65 [ASSUMPTION] | s | kısa mı, boşlukları fazla mı kolaylaştırıyor |
| Süzülürken alçalma | 0,6 | m/s | |
| Jet ışını uzunluğu (vuruş) | 2,6 | m | |
| Pil çekim mesafesi | 1,6 | m | piller "kendiliğinden" toplanıyor hissi var mı |
| Çalı başına pil | 1 | adet | |
| Kamera kendiliğinden dönme | 0,9 | 1/s | |

**Kodda:** `bip.gd` ("Jet süzülme" grubu), `bip_visuals.gd` (`_make_jets`), `battery.gd` (`VACUUM_RANGE`), `scripts/level/decor_react.gd`, `follow_camera.gd`.

## Sıradaki iş (önerilen)
- **Seviye yoğunluğu:** geniş boş zeminlere para dizileri, kırılabilir nesneler, gizli köşeler, tekmelenebilir küçük nesneler (fizik topları, kutular) eklemek.
- **Bölüme özel güç-yükü anı:** Astro Bot'ta her bölümün bir sürpriz oyuncağı var; bizde yetenekler bu rolde, bölüm içinde daha fazla "vay" anı (set-piece) eklenebilir.
- Geliştiricinin telefonda deneyip "hâlâ farklı" dediği yerlere göre sayılar ayarlanacak.

## History
- 2026-11-18: oluşturuldu; jet süzülme, pil çekimi, canlı süsler, sakin kamera eklendi (D-017).
