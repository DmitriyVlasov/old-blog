---
title: Github
linktitle: Github
toc: true
type: docs
date: "2020-02-14T00:00:00+01:00"
draft: false

tags: ["q&a", "Github"]
menu:
  memo:
    parent: Заметки
    weight: 2

# Prev/next pager order (if `docs_section_pager` enabled in `params.toml`)
weight: 1
---

## Как обновить fork на Github

* Задача: Как обновить до актуального состояния по необходимости свой клон проекта из источника.

### Коротко

* Выполнить команду `git pull upstream master`

### Подробнее

* Открыть программу Github
* Открыть интересующий репозиторий
* Выполнить команду "Repository\Open in Command Prompt" или Нажать сочетание клавиш `Ctrl+``
* Выполнить команду `git pull upstream master`
* Закрыть консоль
* Выполнить команду "Repository\Pull"