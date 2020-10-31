+++
# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors = ["Стефан Тольксдорф","Дмитрий Власов"]

# Publication type.
publication_types = ["6"]
featured = true
# Publication name and optional abbreviated version.
date = "2017-01-28"
title = "Учебник библиотеки FParsec"
publication = "Перевод учебника библиотеки FParsec"
abstract = "Этот учебник знакомит вас с основными понятиями библиотеки FParsec. Цель этого учебника это дать вам возможность попробовать создать приложения синтаксического разбора с помощью библиотеки FParsec. Что будет достаточной основой для того, чтобы вы могли в дальнейшем использовать FParsec самостоятельно с помощью руководства пользователя, справочника по API и примеров синтаксических анализаторов."

# Does this page contain LaTeX math? (true/false)
math = false

# Does this page require source code highlighting? (true/false)
highlight = true

# Is this a selected publication? (true/false)
selected = true

# Links (optional)
url_code = "https://github.com/stephan-tolksdorf/fparsec"
url_dataset = "https://github.com/stephan-tolksdorf/fparsec/tree/master/Samples"
url_source = "http://www.quanttec.com/fparsec/tutorial.html"
+++

# Введение

Этот учебник знакомит вас с основными понятиями библиотеки FParsec. Наша цель &mdash; дать вам возможность попробовать создать приложения синтаксического разбора с помощью библиотеки FParsec. Мы охватим только основные идеи и дадим беглый обзор библиотеки по [API](https://ru.wikipedia.org/wiki/API)<sup>en</sup>. Но, надеемся, это будет достаточной основой для того, чтобы вы могли в дальнейшем использовать FParsec самостоятельно с помощью: [руководства пользователя](http://www.quanttec.com/fparsec/users-guide/)<sup>en</sup>, [справочника по API](http://www.quanttec.com/fparsec/reference/)<sup>en</sup> и примеров синтаксических анализаторов в папке [Samples](https://github.com/stephan-tolksdorf/fparsec/tree/master/Samples)<sup>en</sup>.

## Благодарности
Благодарю мою жену Ольгу за помощь в переводе, стилистической выверке и редактуре теста.

# Оглавление
1. [Вступление]( {{< ref "01-preliminaries.md" >}}) 
1. [Синтаксический анализатор числа с плавающей точкой]( {{< ref "02-parsing-a-single-float.md" >}})
1. [Синтаксический анализатор числа с плавающей точкой в скобках]( {{< ref "03-parsing-a-float-between-brackets.md" >}})
1. [Абстрактные синтаксические анализаторы]( {{< ref "04-abstracting-parsers.md" >}})
1. [Синтаксический анализатор списка чисел с плавающей точкой]( {{< ref "05-parsing-a-list-of-floats.md" >}})
1. [Обработка пробелов]( {{< ref "06-handling-whitespace.md" >}})
1. [Синтаксический анализатор строковых данных]( {{< ref "07-parsing-string-data.md" >}})
1. [Использование последовательности синтаксических анализаторов]( {{< ref "08-sequentially-applying-parsers.md" >}})
1. [Использование альтернативных синтаксических анализов]( {{< ref "09-parsing-alternatives.md" >}})
1. [Ограничение значений F#]( {{< ref "10-fsharps-value-restriction.md" >}})
1. [Синтаксический анализ JSON]( {{< ref "11-parsing-json.md" >}}) (В работе)
1. [Куда дальше?]( {{< ref "12-what-now.md" >}}) (В работе)

# Учебник на других языках
- [Стефан Тольксдорф](https://github.com/stephan-tolksdorf), авторский текст на [английском языке](http://www.quanttec.com/fparsec/tutorial.html).
* [Gab_km](https://twitter.com/gab_km), перевод на [японский язык](http://blog.livedoor.jp/gab_km/archives/1437534.html).
  