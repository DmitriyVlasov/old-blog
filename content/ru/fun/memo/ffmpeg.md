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

## Как конвертировать файл flv в mp4?

* Скачиваете и устанавливаете [ffmpeg](https://ffmpeg.org/download.html)
* В командной строке выполняете команду вида `ffmpeg -i "input.flv" "output.mp4"`, где:
  * `"input.flv"` - произвольное имя файла источника
  * `"output.mp4"` - произвольное имя файла приемника.
