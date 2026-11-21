# Başarımlar

Durum: oyunda (2026-11-22). Kod: `scripts/autoload/achievements.gd` (liste ve hesap), `hud.toast` (bildirim),
`hub._open_achievements` (Koleksiyon → Başarımlar).

## Kurallar
1. 22 başarım var. Biri hariç hepsi kayıt verisinden hesaplanır (ayrı sayaç yok): patronlar, Altın Vida, gizli köşe, pil, yıldız, hız, günlük seri, kostüm, iz.
2. "Çizik Bile Yok" olayla verilir: alan baştan başlanıp hiç hasar almadan ve düşmeden bitirilirse (öğretici sayılmaz).
3. Başarımlar oyuncuya aittir (kayıt yuvasına değil), `Settings`'te saklanır; bir kez kazanılır, geri alınmaz.
4. Her başarım 10 bonus pil verir (kostüm ve iz açmaya sayılır).
5. Kazanınca ekranın altında küçük bir bildirim çıkar ("Başarım: ..."); oyunu durdurmaz, birden çoksa sırayla gelir.
6. Kontrol anları: alan sonu, patron yenilince, Koleksiyon açılınca.

## Liste
`achievements.gd` içindeki `LIST` tek kaynak; ad ve açıklamalar orada, İngilizceleri `lang_en.gd` içinde.

## Sayılar
| Ad | Değer |
|---|---|
| Başarım ödülü | 10 bonus pil |
| "Rüzgâr Gibi" | hedef sürenin %75'i |
| Seri başarımları | 3 ve 7 gün |

## Testler
`tests/replay_test.tscn`: hesap, kayıt, ödül, ikinci kez verilmeme.

## Açık konular
- Google Play Games / Game Center başarımlarına bağlı değil; mağaza sürümünde bağlanabilir.
- Hedef süreler ölçülmediği için "Rüzgâr Gibi" çok kolay ya da çok zor olabilir.
