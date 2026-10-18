#!/usr/bin/env bash
# Установка скилла profile и рабочей папки для Claude Code на macOS.
# Запуск:  bash install.sh
# Скрипт ничего не удаляет: если скилл уже стоит, старая версия уезжает в .backup.

set -euo pipefail

# Папка, в которой лежит сам скрипт — чтобы запуск работал из любого места
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILLS_DIR="$HOME/.claude/skills"
VAULT="$HOME/Documents/SMM"

echo ""
echo "  Установка SMM-стартера"
echo "  ──────────────────────"
echo ""

# --- 1. Скиллы ---------------------------------------------------------------
mkdir -p "$SKILLS_DIR"

for skill_path in "$SRC"/skills/*/; do
  skill="$(basename "$skill_path")"
  target="$SKILLS_DIR/$skill"

  # Уже стоит — сохраняем старую версию с отметкой времени, чтобы не потерять правки
  if [ -d "$target" ]; then
    backup="$target.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$backup"
    echo "  ! скилл '$skill' уже был — старая версия тут: $backup"
  fi

  cp -R "$skill_path" "$target"
  echo "  + скилл '$skill' → $target"
done

# --- 2. Рабочая папка --------------------------------------------------------
mkdir -p "$VAULT/profile" "$VAULT/content" "$VAULT/references"
echo "  + рабочая папка → $VAULT"

# CLAUDE.md — файл, который Claude Code читает в начале каждой сессии.
# Пишем только если его нет: перезаписывать чужие правки нельзя.
if [ ! -f "$VAULT/CLAUDE.md" ]; then
  cat > "$VAULT/CLAUDE.md" <<'CLAUDEMD'
# Рабочая папка: Instagram и дизайн

Этот файл Claude Code читает автоматически в начале каждой сессии, открытой
в этой папке. Здесь — карта, а не инструкции на все случаи.

## Структура

| Папка | Что внутри |
|---|---|
| `profile/` | Заметки обо мне: кто я, вкус, голос, цели. Заполняются скиллом `profile` |
| `content/` | Посты, тексты, макеты |
| `references/` | Скриншоты и ссылки на визуал, который нравится |

## Правила

- Отвечай по-русски, на «ты».
- **Перед любой задачей про тексты или дизайн — прочитай `profile/taste.md` и
  `profile/voice.md`.** Это главный источник правды о том, что мне подходит.
  Нет файла — так и скажи, не угадывай за меня.
- Файлы в `profile/` — только с моего явного «да». Это мои личные заметки.
- Не предлагай «универсально красивое». Предлагай то, что сходится с `taste`.

## Что дальше

Путь от профиля до полноценного агента-дизайнера — в `ROADMAP.md` в папке,
откуда шла установка.
CLAUDEMD
  echo "  + $VAULT/CLAUDE.md"
else
  echo "  = $VAULT/CLAUDE.md уже есть, не трогаю"
fi

# Копируем роадмап рядом с рабочей папкой, чтобы он был под рукой
if [ -f "$SRC/ROADMAP.md" ]; then
  cp "$SRC/ROADMAP.md" "$VAULT/ROADMAP.md"
  echo "  + $VAULT/ROADMAP.md"
fi

# --- 3. Проверка -------------------------------------------------------------
echo ""
if [ -f "$SKILLS_DIR/profile/SKILL.md" ]; then
  echo "  Готово ✅"
else
  echo "  Что-то пошло не так: $SKILLS_DIR/profile/SKILL.md не создан." >&2
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo ""
  echo "  ⚠️  Claude Code не найден в системе."
  echo "      Скиллы установлены и будут работать, как только ты его поставишь."
  echo "      Как — в INSTALL.md, шаг 1."
fi

echo ""
echo "  Дальше, по шагам:"
echo "    1) открой Терминал и выполни:  cd ~/Documents/SMM && claude"
echo "    2) напиши в чате:              давай профиль"
echo ""
