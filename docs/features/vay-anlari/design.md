# "Vay" anları (set-piece)

Durum: oyunda (2026-11-22). Kod: `scripts/setpiece/` (`cannon.gd`, `vista.gd`, `setpiece.gd`); yerleşim her alanın
`tools/level/chN_*.py` betiğinin sonunda (`L.cannon`, `L.vista`, `L.setpiece`).

## Amaç
Her alanda oyuncunun "vay!" diyeceği, o alanı hatırlatacak en az bir an olsun. Astro Bot'ta her bölümün bir gösterisi
vardır; bizde üç yapı taşı bunu sağlar. Gösteriler oynanışı durdurmaz ve hasar vermez.

## Yapı taşları
1. **Fırlatma Topu** (`L.cannon(x, y, z, hedef)`): Bip sarı kaideye girince topun içine alınır, top 0,6 saniye nişan alır
   ve Bip'i büyük bir kavisle hedefe fırlatır. Uçuşta oyuncu kontrol etmez, Bip takla atar, kamera uzaklaşır, arkada iz kalır.
   Toplar hep **çift** kurulur: biri ana yoldan pilli bir yan adaya, diğeri geri. Ana yol topsuz da bitirilebilir.
2. **Manzara** (`L.vista(x, y, z, hedef, başlık)`): Bip ilk girince kamera 2,6 saniye alanın yön işaretine döner, adı ekrana gelir.
3. **Gösteri** (`L.setpiece(tür, x, y, z, merkez, ...)`): Bip tetik kutusuna ilk girince `merkez`de bir olay oynar.

| Tür | Ne olur | Kalıcı mı |
|---|---|---|
| `whale` | Mavi balina sudan fırlar, yolun üstünden kavisle geçip geri dalar; iki su sıçraması | hayır (3,2 sn) |
| `skywhale` | Dev balina bulutların arasından 16 saniyede süzülerek geçer | hayır |
| `eruption` | Kızgın kayalar fışkırır, ekran sarsılır; `repeat` ile yinelenir | hayır |
| `fireworks` | 10 havai fişek art arda patlar | hayır |
| `meteor` | 9 kayan yıldız; sonuncusu merkeze düşer | hayır |
| `lightning` | 5 zararsız yıldırım merkezin çevresine düşer | hayır |
| `balloons` | 16 renkli balon aşağıdan yükselir | hayır |
| `beacon` | Dev fener ışını yanar ve dönmeye başlar | evet |
| `aurora` | Gökte kutup ışıkları belirir ve dalgalanır | evet |
| `crystals` | Karanlık mağarada 10 dev kristal sırayla büyüyüp ışıldar | evet |

## Nerede ne var
| Alan | Vay anı |
|---|---|
| Uyanış Atölyesi | çıkış kapısında küçük havai fişek |
| Yay Bahçesi | başta Dev Yay Kulesi manzarası; Çiçek Tepesi'nden gök adasına top (gidiş-dönüş) |
| Balon Kanyonu | Gün Batımı Terası'nda balon şenliği |
| Mıknatıs Fabrikası | Vinç Terası'ndan asılı güverteye top (gidiş-dönüş) |
| Kaya Ocağı | ocakta patlatma (kayalar fışkırır) |
| Liman Rıhtımı | adadan sonra yolun üstünden balina atlar |
| Fener Kulesi | tepeye varınca fenerin ışığı yanar |
| Gemi Mezarlığı | Gemi 1'in güvertesinden gözcü yuvasına korsan topu (gidiş-dönüş) |
| Buz Mağarası | çıkış salonunda kristaller |
| Donmuş Göl | üçüncü gölde balina buzun üstünden atlar |
| Kar Zirvesi | geçitte kutup ışıkları |
| Bulut Basamakları | gök balinası |
| Fırtına Köprüleri | Pervane kulesinin yanına yıldırımlar |
| Kıvılcım Kalesi | bitişte kalenin çevresine yıldırımlar |
| Oyuncak Kasabası | Fındıkkıran'ın şapkasında havai fişek |
| Yıldız Gözlemevi | başta Gözlemevi manzarası; Takımyıldız'dan sonra meteor yağmuru |
| Volkan Adası | başta Volkan manzarası; krater kenarına yaklaşınca volkan patlar (14 saniyede bir yineler) |
| Top Adaları | toplar ana yol: A, B ve üçlü zincir (C→D→E); başta Yıldız Adası manzarası, bitişte havai fişek |
| Şampiyon Yolu | kupa platformunda havai fişek |

## Patronlar
Dövüş başlarken patrona özel bir gösteri, yenilince havai fişek oynar (`area.gd` `BOSS_SHOW`, `_boss_show`).

| Patron | Giriş gösterisi |
|---|---|
| Hurdacı Vinç | tepesinden kızgın hurdalar fışkırır |
| Paslı Kaptan | arkasında balina sudan fırlar |
| Kardan Dev | gökte kutup ışıkları belirir |
| Statik | arkasına yıldırımlar düşer (zararsız; hasar verenlerin yerde uyarı diski olur) |

## Sayılar
| Ad | Değer | Birim |
|---|---|---|
| Top nişan süresi | 0,6 | s |
| Top uçuş süresi | 1,7 | s |
| Kavis tepesi (yüksek ucun üstünde) | 6 | m |
| Uçuşta kamera uzaklaşması | 6 | m |
| Manzara süresi | 2,6 | s |

## Kurallar
- Gösteri her alana girişte bir kez oynar (kalıcı değil; alana yeniden girince yine oynar).
- Gösteri hasar vermez ve yolu kapatmaz. Zararsız yıldırımlar yoldan uzağa düşer (Bölüm 4 patronunun yıldırımıyla karışmasın).
- Topun hedefi başka bir topun kaidesine ya da bir düşmanın üstüne denk gelmemeli (en az 3 m uzak).
- Köşeli alanlarda hedefler tasarım koordinatıyla yazılır; `lvl.py` dünya yönünü kendisi hesaplar.

## Testler
`tests/setpiece_test.tscn`: her alanda en az bir vay anı var; top Bip'i hedefe indirir ve kontrolü geri verir; her gösteri
türü hatasız oynar, geçici olanlar arkasını temizler.

## Açık konular
- Hiçbiri telefonda oynanarak denenmedi: topun süresi/kavisi mide bulandırıyor mu, manzara kamerası başta rahatsız ediyor mu bakılmalı.
- Topların ana yol olduğu alan: Top Adaları (Bölüm 5). Diğer alanlarda toplar yan yol.
- Gösterilerin kendine özel sesi yok; eldeki efektler alçak perdede kullanılıyor.
