# Bölüm 1: Uyanış

**Status:** designed · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Oyuncunun ilk bölümü. İlk ~6 dakika, ölmenin imkânsız olduğu bir atölyede hareketi, zıplamayı, ilk kopyalamayı ve yeteneğin kalkan olduğunu yazısız öğretir. Ardından dört alan ve bir patronla yaklaşık 35 dakikalık asıl oynanış gelir. Her alan aynı ritmi izler: **öğret → sına → şaşırt → ustalık**. Hikaye: [hikaye](../hikaye/design.md).

## Öğretici: Uyanış Atölyesi (~0:45–6:00)
Kurallar: bu alanda çukur, düşme ölümü ve can göstergesi yoktur; bir şey ters giderse Bip her zaman yürüyerek geri dönebilir. Tuş simgesi yalnızca oyuncu bir şeyi 4 saniye boyunca yapmazsa Pırıl'ın üstünde belirir ve son kullanılan girdi cihazına göre (dokunmatik / klavye / gamepad) çizilir (D-005).

| Zaman | Ne öğrenilir | Oyun alanı nasıl öğretir | Ödül |
|---|---|---|---|
| 0:45–1:30 | Yürümek, kamera kendiliğinden takip | Bip şarj istasyonunda uyanır; Pırıl kapıya uçar. Kıvrılan dar bir koridor; yerde bir sıra pil yolu gösterir. | ilk 10 pil, toplama sesi |
| 1:30–2:30 | Zıplama, kısa/uzun zıplama | Önce 0,5 m'lik kutu, sonra 1,2 m'lik boşluk (altı alçak zemin, rampayla geri dönülür). Bir rafın üstündeki pil için tuşu basılı tutmak gerekir. | pil yayı |
| 2:30–3:15 | Kamerayı elle çevirmek (isteğe bağlı) | Kasanın arkasına saklanmış parlayan bir pil. Sadece etrafa bakan bulur; atlanabilir. | 5 pil |
| 3:15–4:30 | İlk kopyalama: **Yay** | Bip sığ bir çukura iner; tek çıkış yukarıda. Çukurda tek nesne bir yay; Pırıl üstünde döner, anten ışığı yanar. Kopyalayınca süper zıplama ile dışarı. Sonra yükselen üç yaylı basamak. | pil yayı, Bip'in renk değişimi |
| 4:30–5:30 | İlk düşman, üstüne zıplama, yeteneğin kalkan olması | Yavaş bir "Vidaböcek". Üstüne zıplanınca vida saçarak dağılır. Çarpılırsa can gitmez, Yay kaybolur; hemen yanında yeni bir yay vardır. | ilk can göstergesi belirir |
| 5:30–6:00 | Dinlenme, yön | Atölye kapısı açılır, vadi manzarası ve uzakta karanlık kule (hikaye). İlk kontrol noktası ve otomatik kayıt. | — |

Gizli **Altın Vida #1:** atölyenin en üst rafında; yalnızca Yay ile ve rafların arkasından dolaşılarak ulaşılır.

## Alanlar (~6:00–40:00)
| # | Alan | Süre | Öğret | Sına | Şaşırt | Ustalık |
|---|---|---|---|---|---|---|
| 1 | Yay Bahçesi | ~7 dk | yaylarla basamaklar, ilk gerçek çukurlar | hareketli platformlarda yaylar | yayların kendisi platformda hareket eder; yay ile düşmanları ezmek | Vidaböcek'lerle dolu dönen yay kulesi |
| 2 | Balon Kanyonu | ~7 dk | **Balon** ile kısa boşlukları süzülerek geçmek | uzun boşluklar, kaybolan platformlar | rüzgâr akımları balonla Bip'i yukarı taşır | rüzgâr değiştiren pervaneler arasında uzun bir süzülüş |
| 3 | Mıknatıs Fabrikası | ~8 dk | **Mıknatıs** ile metal duvara çekilmek | konveyör bantlar, metal zincir atlayışı | Yay ile Mıknatıs arasında gidip gelmek; düşman zırhını mıknatısla sökmek | dönen metal çarklar üzerinde tırmanış |
| 4 | Kaya Ocağı | ~7 dk | **Kaya** ile ağır buton, çatlak zemin | zaman sınırlı kapılar, ezilecek düşmanlar | Kaya ile dibe batıp suyun altındaki yolu bulmak | dört yeteneği sırayla isteyen final parkuru |
| 5 | Patron: Hurdacı Vinç | ~4 dk | — | aşama 1: düşen hurdalardan kaç, Yay ile kancaya zıpla | aşama 2: rüzgâr kollarını Balon ile geç | aşama 3: Mıknatıs ile metal kola yapış, tepede Kaya ile kabine çakıl → Çekirdek Pil düşer |

Her alanda bir **Altın Vida** (toplam 5), ana yoldan sapan ve alanın yeteneğinin zekice bir kullanımını isteyen bir köşede.

## Rules
1. Kontrol noktaları 60–90 saniyede bir ve her alan geçişinde; her biri otomatik kaydeder ([kayıt](../kayit/design.md)).
2. Bip'in 3 canı vardır. Çukura düşmek 1 can götürür ve Bip son kontrol noktasında belirir. Canlar biterse "oyun bitti" ekranı yoktur: Bip son kontrol noktasından tam canla devam eder.
3. Toplanan piller ve vidalar ölünce kaybolmaz.
4. Her alan bir önceki alanın yeteneğini en az bir kez yeniden kullandırır.
5. Zorluk testere dişi gibi artar: her zor bölümden önce ve sonra bir dinlenme yeri (manzara, pil yağmuru, güvenli alan) vardır.
6. Oyuncu aynı yerde 3 kez ölürse Pırıl doğru yolun üstünde belirir (ayarlardan kapatılabilir).
7. Yön, duvarla değil ışık, pil sıraları ve uzaktaki kule gibi yer işaretleriyle gösterilir.
8. Gereken boşluklar Bip'in ölçülen zıplama mesafesinin ~%70'i, isteğe bağlı zorluklar ~%95'i kadar tasarlanır ([hareket](../hareket/design.md)).

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Öğretici süresi | 5–6 [ASSUMPTION] | dk | yeni oyuncu takılıyor mu, deneyimli sıkılıyor mu |
| Tuş simgesi gecikmesi | 4 [ASSUMPTION] | s | |
| Kontrol noktası aralığı | 60–90 | s oynanış | |
| Can | 3 | | |
| Bölüm toplam pil | 150 [ASSUMPTION] | adet | |
| Altın vida | 5 | adet | |
| Pırıl ipucu eşiği | 3 | ölüm, aynı yerde | |
| Toplam süre (ilk oynayış) | ~40 [ASSUMPTION] | dk | |

## Edge cases
- Oyuncu öğreticide yayı kopyalamadan çukurdan çıkmaya çalışırsa: duvarlar yayla ulaşılabilir yükseklikten fazladır, takılırsa simge çıkar.
- Oyuncu Yay'ı kaybedip yeni yay bulamazsa: zorunlu bir yetenek gereken her yerin yakınında kopyalanabilir nesne bulunur (soft-lock olmamalı).
- Yeteneği bırakan ya da yanlış yeteneği alan oyuncu geri dönüp doğru nesneyi bulabilmeli.
- Kontrol noktasından devam ederken oyuncu, o noktaya ulaştığı andaki yetenekle başlar.

## Open questions
- [ASSUMPTION] Alan süreleri ve pil sayısı; greybox oynandıktan sonra ayarlanacak.
- Bölüm sonunda zaman/pil derecelendirmesi (yıldız) olsun mu? Şimdilik hayır.

## History
- 2026-11-18: Patron aşamalarının başında ne yapılacağı yazıyla söylenir (patron betiğinde `PHASE_HINTS`); sıradaki hedefin ve gereken yeteneğin kaynağının üstünde sarı ok durur (`goal_nodes()`, `area.gd`). Geliştirici Paslı Kaptan 2. aşamada ne yapacağını bulamadı.
- 2026-11-18: Kaya Ocağı'nda mağara çıkışı ve havuz çıkışı rampaları ters eğimliydi (oyuncu çatlak zemini kırdıktan sonra uçurum kenarına geliyordu); düzeltildi, test eklendi.
- 2026-11-18: tasarlandı.
