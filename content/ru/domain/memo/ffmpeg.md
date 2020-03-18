---
title: Ffmpeg
linktitle: Ffmpeg
toc: true
type: docs
date: "2020-02-14T00:00:00+01:00"
draft: false

tags: ["q&a", "ffmpeg"]
menu:
  memo:
    parent: Заметки
    weight: 2

# Prev/next pager order (if `docs_section_pager` enabled in `params.toml`)
weight: 1
---

Универсальный видео и аудио конвертор и декодер можете скачать с сайта [ffmpeg](https://ffmpeg.org/download.html) 

## Как конвертировать файл flv в mp4?

* Скачиваете и устанавливаете [ffmpeg](https://ffmpeg.org/download.html)
* В командной строке выполняете команду вида `ffmpeg -i "input.flv" "output.mp4"`, где:
  * `"input.flv"` - произвольное имя файла источника
  * `"output.mp4"` - произвольное имя файла приемника.

## Как конвертировать файл flv в ogg?

* Скачиваете и устанавливаете [ffmpeg](https://ffmpeg.org/download.html)
* В командной строке выполняете команду вида `ffmpeg -i <input> -c:a libopus -b:a <bitrate> <output>`, где:
  * `*<input>*` - Файл ввода, может быть в любом поддерживаемом ffmpeg формате. 
  * `<bitrate>` - Указываете битрейт в формате цифра плюс буква, например `96K` для 96 kBit/s.
  * `<output>` - Файл вывода, например `result.ogg`