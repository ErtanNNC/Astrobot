# Dil (Türkçe / İngilizce)

Oyunun kaynak dili Türkçe; İngilizce çeviri mağazalarda Türkiye dışına çıkabilmek için eklendi.

## Rules
1. Dil ilk açılışta cihazın diline göre seçilir: Türkçe cihazda Türkçe, diğer bütün dillerde İngilizce.
2. Oyuncu Ayarlar → **Dil** düğmesiyle değiştirir; seçim ayarlar dosyasında saklanır (`Settings.language`).
3. Çeviri tablosu `scripts/ui/lang_en.gd` (`LangEn.MESSAGES`): anahtar Türkçe metnin kendisidir.
4. Düz metinli `Label` ve `Button`'lar kendiliğinden çevrilir. Biçimli metinlerde (`%d`, `%s`), birleştirilen metinlerde, `Label3D`'lerde ve elle çizilen yazılarda kodda `tr("...")` kullanılır (statik fonksiyonlarda `TranslationServer.translate`).
5. Yeni bir metin eklendiğinde aynı commit'te `lang_en.gd`'ye çevirisi eklenir.
6. Özel adlar çevrilir (Pırıl → Sparkle, Paslı Kaptan → Rusty Captain); "Bip" çevrilmez.

## Edge cases
- Tabloda olmayan metin Türkçe görünür (hata vermez).
- Düğme simgeleri metnin başındaki Türkçe kelimeye göre seçilir; `UIKit.icon_for` çevrilmiş metni de tanır.
- Uzayan İngilizce metinler pencereyi büyütürse pencere ekrana sığacak kadar küçülür (`UIKit.fit_scale`).

## History
- 2026-11-21: ilk sürüm (yaklaşık 200 metin).
