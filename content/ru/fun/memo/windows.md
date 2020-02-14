---
title: Windows
linktitle: Windows
toc: true
type: docs
date: "2020-02-14T00:00:00+01:00"
draft: false

tags: ["q&a", "windows","taskkill"]
menu:
  memo:
    parent: Заметки
    weight: 2

# Prev/next pager order (if `docs_section_pager` enabled in `params.toml`)
weight: 1
---

## Как завершить работу приложения в Windows из командной строки?

* Задача: Нужно закрыть Excel и все открытые файлы без сохранения. Можно решить это с помощью команды `TASKKILL`.

```
TASKKILL /im excel.exe /t /f
```

* Подробнее о команде в официальной документации [`TASKKILL`](https://docs.microsoft.com/ru-ru/windows-server/administration/windows-commands/taskkill).
