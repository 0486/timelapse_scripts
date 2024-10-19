# Таймлапс Скрипт

Цей скрипт призначений для створення таймлапс відео з RAW зображень (Поки тільки формат Nikon .NEF).
Скрипт створений для уникнення на відео градієнта, який з'являється при створенні таймлапсів із ряду JPEG-файлів.
Він конвертує RAW файли у TIFF, дозволяє застосовувати автоматичний баланс білого та об'єднувати кадри у відео з вибором роздільної здатності, значенням CRF та додатковими відеофільтрами.
Результат - відео з відеокодеком hevc (h265), контейнер QuickTime, формат пікселя дозволяє відтворювати у більшості соціальних мереж та месенджерів.

## Автори
- **Rostyslav Golda, 2024**
- **ChatGPT by OpenAI, 2024**

## Ліцензія
Цей скрипт доступний під ліцензією MIT. Деталі див. у файлі `LICENSE`.

## Залежності

Для роботи скрипта необхідні наступні програми:

- **dcraw**: для конвертації .NEF файлів у TIFF.
- **ffmpeg**: для об'єднання кадрів у відео.
- **GNU Parallel**: для розпаралелювання завдань.
- **ImageMagick**: для застосування автоматичного балансу білого (опціонально).

### Встановлення залежностей

#### Debian/Ubuntu
```bash
sudo dnf install dcraw ffmpeg parallel ImageMagick
```

#### Fedora
```bash
sudo dnf install dcraw ffmpeg parallel ImageMagick
```

#### Arch Linux
```bash
sudo pacman -S dcraw ffmpeg parallel imagemagick
```

## Використання
### Загальний формат команди
```bash
./timelapse.sh [1080p|2k|4k|5k] [crf (необов'язково)] [відеофільтри (необов'язково)] [--autowb]
```

## Параметри

- **Роздільна здатність (обов'язково)**: виберіть бажану роздільну здатність для вихідного відео. Можливі варіанти:
  - `1080p` — Full HD (1920x1080)
  - `2k` — Quad HD (2560x1440)
  - `4k` — Ultra HD (3840x2160)
  - `5k` — (5120x2880)

- **CRF (необов'язково)**: вкажіть значення CRF (контроль якості) для стиснення відео. Якщо не вказано, за замовчуванням використовується `23`.

- **Відеофільтри (необов'язково)**: можна додати додаткові відеофільтри, які будуть застосовані під час обробки.

- **`--autowb`**: опція для автоматичного балансу білого на основі ImageMagick. Застосовується для всіх кадрів перед створенням відео.

## Приклади використання

### Конвертація з автоматичним балансом білого у 4K
```bash
./timelapse.sh 4k 20 --autowb
```

### Конвертація у Full HD без додаткових опцій
```bash
./timelapse.sh
```

### Конвертація у 2k з підвищенням контрасту чіткості та колірності
```bash
./timelapse.sh 2k 23 "eq=saturation=1.5:contrast=1.3:brightness=0.1,unsharp"
```

## Авторські Права
(C) Rostyslav Golda 2024, (C) OpenAI 2024
