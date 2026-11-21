# Düşmanlar

Durum: oyunda (2026-11-21). Kod: `scripts/entities/enemy.gd`, `scripts/entities/enemy_shot.gd`.

## Amaç
Her düşman oyuncuya tek bir soru sorar ve cevabı farklıdır. Böylece aynı platformda iki farklı düşman
yan yana gelince oyuncu düşünmek zorunda kalır.

| Tür (`kind`) | Soru | Nasıl yenilir | Ne yapar |
|---|---|---|---|
| `vidabocek` | "Üstüne basabilir misin?" | Üstüne bas ya da Vuruş | İki nokta arasında yürür |
| `zipzip` | "Zamanlamayı tutturabilir misin?" | Üstüne bas ya da Vuruş | Yerinde zıplar, yaklaşınca sana doğru seker |
| `hurdaci` | "Kaçarken de oynayabilir misin?" | Üstüne bas ya da Vuruş | Görünce kovalar, uzaklaşınca evine döner |
| `atici` | "Uzaktan gelen tehlikeyi görüyor musun?" | Üstüne bas ya da Vuruş | Havada asılı durur, şişer ve mermi yollar |
| `dikenli` | "Her şeye basılmaz, fark ettin mi?" | Yalnızca Vuruş ya da Kaya çakılması | Vidaböcek gibi yürür; sırtı dikenli |

## Atıcı
- Yerden 1,3 m yukarıda asılı durur, yerinden ayrılmaz.
- Bip 13 m'den yakınsa 2,6 saniyede bir atış yapar.
- Atıştan önce 0,55 saniye şişer (oyuncuya haber). Şişme görülmeden mermi çıkmaz.
- Mermi 6,5 m/s hızla düz gider, 3,5 saniye sonra söner. Yürüyen Bip'ten yavaş değil ama yana bir adım yeter.
- Mermi Bip'e değerse 1 can götürür. Bip o an Vuruş yapıyorsa mermi söner, can gitmez.
- Görünüş: Quaternius "Wasp" (her bölümde aynı; uçan tek model).

## Dikenli
- Vidaböcek ile aynı yürüyüş (`patrol`, `speed`).
- Sırtında kırmızı koniler var: üstüne basan Bip 1 can kaybeder, düşman ölmez.
- Vuruş (dönme saldırısı) ya da Kaya çakılması yener.
- Görünüş: bölümün Vidaböcek modeli + koddan eklenen kırmızı dikenler (kırmızı = "basma" işareti).

## Yerleştirme kuralları
- Yeni tür ilk kez güvenli bir yerde gösterilir: yoldan uzakta ya da çözümü veren yeteneğin hemen yanında.
- Atıcı dar köprünün ya da hareketli platformun üstüne konmaz; oyuncunun yana kaçacak yeri olmalı.
- Dikenli, Vuruş açılmadan önceki alanlara yalnızca Kaya kaynağının yanına konur.

| Alan | Atıcı | Dikenli |
|---|---|---|
| B2 Fener | ilk tanışma: yolun dışında, sandığın yanında | |
| B3 Gemi Mezarlığı | | ilk tanışma: Kaya kaynağının yanında |
| C3 Zirve | 1 | 1 |
| D1b Fırtına Köprüleri | 1 | 1 |
| D2 Kıvılcım Kalesi | 1 | 1 |
| E1 Oyuncak Kasabası | | 1 |
| E2 Yıldız Gözlemevi | 1 | |
| E3 Volkan Adası | 1 | 1 |
| E4 Şampiyon Yolu | 1 | 1 |

## Patron saldırı desenleri (2026-11-22)
2. aşamadan itibaren her patronun her 3. saldırısı tek mermi yerine bir desendir (`scripts/boss/boss_patterns.gd`).
Her merminin yerde dolan uyarı diski vardır; her desenin güvenli yeri bellidir.

| Patron | Desen | Güvenli yer |
|---|---|---|
| Hurdacı Vinç | patrondan oyuncuya doğru 4 hurdalık sıra | yana bir adım |
| Paslı Kaptan | 3,2 saniyede bir güverteye hurda (yeni); 2. aşamada sıra hâlinde | yana bir adım; patrona 3,5 m'den yakınken düşmez |
| Kardan Dev | oyuncunun çevresinde 6 kartopluk halka (yarıçap 3,2 m) | ortada dur |
| Statik | artı biçiminde 9 yıldırım | çapraza kaç |

Sayılar telefonda denenmedi [ASSUMPTION]; zor gelirse `BossPatterns.EVERY` büyütülür.

## Testler
`tests/ch2_test.gd`: Atıcı mermi yollar; Dikenli'ye basınca can gider ve düşman ölmez; Vuruş Dikenli'yi yener.
