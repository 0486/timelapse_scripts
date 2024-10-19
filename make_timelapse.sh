#!/bin/bash

###############################################################################
# Скрипт для створення таймлапс відео з RAW зображень                          #
# Автори: Rostyslav Golda, ChatGPT by OpenAI                                  #
# Копірайт: (C) Rostyslav Golda 2024, (C) OpenAI 2024                         #
# Ліцензія: MIT License                                                       #
###############################################################################

# Перевірка наявності параметрів
if [[ $# -lt 1 ]]; then
  echo "Використання: $0 [1080p|2k|4k|5k] [crf (необов'язково)] [відеофільтри (необов'язково)] [--autowb]"
  exit 1
fi

# Встановлення роздільної здатності на основі введеного параметра або за замовчуванням
RESOLUTION="1920:1080" # Значення за замовчуванням (1080p)
if [[ -n $1 ]]; then
  case $1 in
    1080p)
      RESOLUTION="1920:1080"
      ;;
    2k)
      RESOLUTION="2560:1440"
      ;;
    4k)
      RESOLUTION="3840:2160"
      ;;
    5k)
      RESOLUTION="5120:2880"
      ;;
    *)
      echo "Неправильна опція. Використовуйте: 1080p, 2k, 4k, або 5k."
      exit 1
      ;;
  esac
fi

# Збереження значення crf або за замовчуванням 23
CRF=${2:-23}

# Підрахунок кількості .NEF і .tiff файлів
nef_count=$(ls -1 *.NEF 2>/dev/null | wc -l)
tiff_count=$(ls -1 frame*.tiff 2>/dev/null | wc -l)

# Перевірка наявності .NEF файлів
if [[ $nef_count -eq 0 ]]; then
  echo "Не знайдено .NEF файлів у поточній директорії."
  exit 1
fi

# Визначення кількості ядер процесора для розпаралелення
num_cores=$(nproc)

# Конвертація .NEF файлів у 16-бітні TIFF за допомогою dcraw (якщо необхідно)
if [[ $tiff_count -ne $nef_count ]]; then
  echo "Конвертація .NEF файлів у TIFF з використанням $num_cores потоків..."
  ls *.NEF | parallel -j "$num_cores" --bar 'dcraw -T -6 -W -w -o 1 "{}"'

  # Перейменування TIFF файлів у послідовний формат
  echo "Перейменування файлів..."
  a=1
  for i in DSC_*.tiff; do
    new=$(printf "frame%04d.tiff" "$a")
    mv -- "$i" "$new"
    a=$((a + 1))
  done
else
  echo "Конвертація пропущена: знайдено $tiff_count .tiff файлів, що відповідає кількості .NEF."
fi

# Автоматичний баланс білого (якщо вказана опція --autowb)
if [[ "$*" == *"--autowb"* ]]; then
  echo "Застосування автоматичного балансу білого з використанням $num_cores потоків..."
  ls frame*.tiff | parallel -j "$num_cores" --bar 'convert "{}" -auto-level -auto-gamma "autowb_{}"; mv "autowb_{}" "{}"'
fi

# Застосування відеофільтрів (якщо вказані)
video_filters=""
if [[ -n $3 && "$3" != "--autowb" ]]; then
  video_filters="$3,"
fi

# Створення таймлапс відео за допомогою ffmpeg
echo "Створення таймлапс відео у $RESOLUTION з частотою кадрів 14.985 fps і CRF $CRF..."
ffmpeg -framerate 14.985 -i frame%04d.tiff -vf "${video_filters}scale=$RESOLUTION:force_original_aspect_ratio=decrease,pad=$RESOLUTION:(ow-iw)/2:(oh-ih)/2" -c:v libx265 -pix_fmt yuv420p10le -crf "$CRF" -movflags +faststart output_${1}.mov

echo "Готово! Відео збережено як output_${1}.mov"
