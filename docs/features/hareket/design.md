# Hareket

**Status:** implemented (M1) · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Bip koşar, zıplar ve havada yön değiştirir. Kontroller anında tepki vermeli ve oyuncunun küçük hatalarını affetmeli: kenardan yeni düştüysen hâlâ zıplayabilirsin, yere değmeden hemen önce bastıysan zıplama yine gerçekleşir. "Önce his" pillar'ının temelidir; diğer her özellik bu sayıların üzerine kurulur.

## Rules
1. Bip `CharacterBody3D`'dir; hareket yönü kameraya göredir (joystick "yukarı" = kameranın baktığı yön).
2. Yerdeyken hız, hedef hıza ivmelenerek ulaşır; girdi bırakılınca yavaşlayarak durur. Bip hareket yönüne doğru yumuşakça döner.
3. Zıplama tuşuna basılınca Bip zıplar; tuş tepe noktasından önce bırakılırsa yukarı hız kesilir (kısa zıplama), basılı tutulursa tam yüksekliğe ulaşır.
4. Düşerken yerçekimi artar (daha ağır, daha kontrollü iniş).
5. **Coyote time:** kenardan düştükten sonra kısa bir süre daha zıplanabilir.
6. **Zıplama tamponu:** yere inmeden kısa süre önce basılan zıplama, inişte otomatik gerçekleşir.
7. Havada yön kontrolü vardır ama yerdekinden zayıftır.
8. İnişte toz efekti ve iniş sesi; zıplamada Bip dikeyde uzar, inişte ezilir.
9. **Hareketler ilerledikçe açılır** (D-016): Bip oyun ilerledikçe güçlenir. Açılma sırası: Kenara Tutunma baştan, Dönme Saldırısı Uyanış Atölyesi'nden sonra, Havada Atılma Bölüm 1 bitince, Duvar Zıplaması Bölüm 2 bitince, Çift Zıplama Bölüm 3 bitince. Açıklık "ulaşılan en ileri alan"dan hesaplanır (eski kayıtlar da kendi ilerlemesine göre açılır); yeni açılan hareket bir sonraki alanın başında "Yeni hareket!" yazısıyla bir kez duyurulur.
10. **Kenara tutunma:** düşerken bir kenara doğru gidiliyorsa ve kenar ayağın 0,6–1,55 m üstündeyse Bip tutunur. Zıpla ya da ileri bas → yukarı çık; geri bas ya da Vuruş → bırak. Hareketli platformların kenarında da asılı kalınır.
11. **Dönme saldırısı (Vuruş butonu):** Bip döner, menzildeki düşmanları ve sandıkları vurur; dönerken düşmana değmek hasar vermez. Havada her zıplamada bir kez yapılabilir ve kısa süre asılı tutar. Patronlar dönmeyle hasar almaz (patron kuralları değişmedi).
12. **Havada atılma:** havada Vuruş ilk basışta ileri hamle (yükseklik kaybetmeden) + dönme olur; iniş, kenara tutunma ya da duvar zıplaması hakkı yeniler.
13. **Duvar zıplaması:** havada duvara doğru gidilirken Bip duvarda yavaş kayar; zıplayınca duvardan karşıya seker (kısa süre yön kilitli). Kaya, Balon süzülmesi ve Pervane yükselişi sırasında olmaz.
14. **Çift zıplama:** havada bir kez daha zıplanır (Kaya hariç). Yere çok yakınken basılan zıplama çift zıplamayı harcamaz, inişte normal zıplamaya dönüşür.
15. **Jet süzülme** (baştan açık, D-017): havada yükselme bitince Zıpla basılı tutulursa kısa süre asılı kalınır; bkz. [oyun hissi](../oyun-hissi/design.md).

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Bip boyu | 1,0 | m | ölçek referansı; tüm seviye buna göre |
| Koşu hızı | 7,0 [ASSUMPTION] | m/s | çok hızlıysa platformlar kaçırılıyor mu |
| Yerde ivmelenme | 45 [ASSUMPTION] | m/s² | ilk adım ağır mı |
| Yerde yavaşlama | 60 [ASSUMPTION] | m/s² | kayıyor mu |
| Havada kontrol çarpanı | 0,65 [ASSUMPTION] | × ivme | havada yön değiştirmek yeterli mi |
| Dönüş hızı | 12 [ASSUMPTION] | rad/s | dönüş keskin mi, robotik mi |
| Tam zıplama yüksekliği | 2,2 [ASSUMPTION] | m | 1,5 m'lik basamak rahat mı |
| Tepeye çıkış süresi | 0,38 [ASSUMPTION] | s | zıplama süzülüyor mu |
| Düşüş yerçekimi çarpanı | 1,8 [ASSUMPTION] | × yerçekimi | iniş "ağır ve net" mi |
| Erken bırakma hız çarpanı | 0,5 [ASSUMPTION] | × yukarı hız | kısa zıplama yeterince kısa mı |
| Maksimum düşüş hızı | 20 [ASSUMPTION] | m/s | |
| Coyote time | 0,10 [ASSUMPTION] | s | kenarda kaçan zıplama kalıyor mu |
| Zıplama tamponu | 0,12 [ASSUMPTION] | s | |
| Tutunma: kenar yüksekliği (ayaktan) | 0,6 – 1,55 [ASSUMPTION] | m | kenarlar kaçıyor mu / istemeden tutunuluyor mu |
| Tutunma: asılı ayak, kenarın altında | 1,05 | m | |
| Kenardan çıkış sıçrayışı | 1,75 | m | |
| Dönme süresi / bekleme | 0,35 / 0,45 [ASSUMPTION] | s | art arda basmak rahat mı |
| Dönme menzili | 1,6 [ASSUMPTION] | m | düşmana yakın durmak gerekiyor mu |
| Havada dönme asılı kalma hızı | 2,5 | m/s | |
| Havada atılma hızı / süresi | 11 / 0,22 [ASSUMPTION] | m/s, s | ~2,5 m ileri |
| Duvarda kayma hızı (en fazla) | 2,5 [ASSUMPTION] | m/s | |
| Duvar zıplaması yüksekliği / itiş | 2,0 / 7,0 [ASSUMPTION] | m, m/s | iki duvar arası tırmanılıyor mu |
| Duvar zıplaması yön kilidi | 0,22 | s | |
| Çift zıplama yüksekliği | 1,7 [ASSUMPTION] | m | |

Yerçekimi ve zıplama hızı, yükseklik ve süreden hesaplanır: `g = 2h / t²`, `v = 2h / t`. Sayılar tek yerde (`@export` değişkenleri ya da bir ayar dosyası) tutulur.

**Kodda:** `scripts/player/bip.gd` (`@export` değişkenleri, Inspector'da "Koşu", "Zıplama", "Zemin" grupları). Yerçekimi her karede yarım adım önce, yarım adım sonra uygulanır; böylece ölçülen zıplama tam 2,2 m çıkar (otomatik test: `tests/m1_movement_test.gd`).

## Edge cases
- Eğimli zeminde kayma olmamalı; 40°'den dik yüzeyler duvar sayılır [ASSUMPTION].
- Hareketli platformda Bip platformla birlikte taşınır.
- Tavana çarpınca yukarı hız sıfırlanır.
- Duraklatmada tampon ve coyote sayaçları sıfırlanır.
- Kare hızı düşse de zıplama yüksekliği değişmemeli (fizik `_physics_process` içinde).

## Open questions
- [ASSUMPTION] Tüm sayılar ilk tahmin; M1'de oynanarak ayarlanacak.
- Uzun atlama veya yuvarlanma gibi ek hareketler eklensin mi? Şimdilik hayır; geliştirici isteğiyle tutunma, dönme, atılma, duvar zıplaması ve çift zıplama eklendi (D-016).
- Eski alanlar yeni hareketler düşünülmeden tasarlandı; ileride gizli piller/robotlar için yeni hareket gerektiren köşeler eklenebilir.

## Uygulama notları (M1)
- Kural 8 tamam: iniş sesi (düşüş hızına göre şiddetli), toz, uzama/ezilme, telefonda kısa titreşim. Ayrıca zıplama ve adım sesi var (`scripts/player/bip_visuals.gd`).
- Bip'in görünüşü Quaternius "Animated Robot" modeli (0,2 ölçek → 1,0 m). Animasyonlar: durma, yürüme, koşu (hıza göre), zıplama; 6 sn hareketsiz kalınca el sallar. Çarpışma şekli değişmedi (0,35 m yarıçaplı, 1 m kapsül).
- Hesap: tam koşuyla zıplamada havada kalma ~0,66 s, yatay menzil ~4,6 m. Test alanında 2 m rahat, 3 m orta, 4 m zor.

## Ek (2026-11-18)
- Bip'in altında her zaman yuvarlak bir iniş gölgesi var (`bip_visuals.gd`): havadayken nereye ineceğini gösterir, yükseldikçe küçülür ve silikleşir (telefonda derinlik algısı için).
- Hızlı koşarken ayaklardan küçük toz bulutları çıkar.

## History
- 2026-11-20: Hata düzeltmesi: kenara tutunma seviyelerin CSG zeminlerinde çalışmıyordu (yalnız StaticBody3D kabul ediliyordu); `moves_test` artık CSG kutuyla dener.
- 2026-11-18: Geliştirici isteğiyle 5 hareket eklendi, ilerledikçe açılır (kural 9-14). Kod: `bip.gd` "Hareketler" grubu, `GameState.MOVES`; test: `tests/moves_test.tscn`.
- 2026-11-18: tasarlandı.
- 2026-11-18: görsel sürüm: robot modeli, animasyonlar, sesler eklendi; sayılar değişmedi.
- 2026-11-18: M1'de uygulandı; tüm sayılar dokümandaki gibi. Otomatik test geçiyor (2 m boşluk, 1,5 m basamak, coyote time, zıplama tamponu).
