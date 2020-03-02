---
title: Markdown
linktitle: Markdown
toc: true
type: docs
date: "2020-02-14T00:00:00+01:00"
draft: false

tags: ["q&a", "Markdown"]
menu:
  memo:
    parent: Заметки
    weight: 2

# Prev/next pager order (if `docs_section_pager` enabled in `params.toml`)
weight: 1
---

## Где посмотреть возможности Markdown?

[Учебник по markdown](https://commonmark.org/help/tutorial/index.html) от разработчиков протокола [Commonmark](https://commonmark.org).

## Как регулировать размер изображения в маркдаун?

[Маркдаун]((https://commonmark.org/help/tutorial/08-images.html)) этого не позволяет сделать.
[Используйте](https://github.com/hakimel/reveal.js/issues/1349) html тэг `img`, например так

```
<img src="image" width="40%">
```