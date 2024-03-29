+++
weight = 4

# Publication type.
publication_types = ["6"]

# Publication name and optional abbreviated version.
date = "2017-01-28"
title = "Глава 4. Абстрактные синтаксические анализаторы"
publication = "Учебник библиотеки FParsec"

# Does this page contain LaTeX math? (true/false)
math = false

# Does this page require source code highlighting? (true/false)
highlight = true

# Is this a selected publication? (true/false)
selected = false

# Links (optional)
url_source = "http://www.quanttec.com/fparsec/tutorial.html#abstracting-parsers"
+++

Одной из самых больших сильных сторон FParsec является легкость, с которой вы можете определить свои собственные абстрактные синтаксические анализаторы.

Возьмем, к примеру `floatBetweenBrackets` из предыдущей главы. Если вы намерены также разобрать другие элементы между строк, вы можете определить свой собственный специализированный комбинатор для этой цели:
```fsharp
let betweenStrings s1 s2 p = str s1 >>. p .>> str s2
```

Затем можно определить `floatInBrackets` и другие синтаксические анализаторы с помощью этого комбинатора:
```fsharp
let floatBetweenBrackets = pfloat |> betweenStrings "[" "]"
let floatBetweenDoubleBrackets = pfloat |> betweenStrings "[[" "]]"
```

{{% callout note %}}
В случае, если вы новичок в F#: `pfloat |> betweenStrings "[" "]"` это просто еще один способ, чтобы написать `betweenStrings "[" "]" pfloat`.
{{% /callout %}}

В тот момент, как вы заметите, что вам часто нужно применять синтаксический анализатор между двумя другими, вы можете пойти дальше, представив функцию `betweenStrings` следующим образом:
```fsharp
let between pBegin pEnd p  = pBegin >>. p .>> pEnd
let betweenStrings s1 s2 p = p |> between (str s1) (str s2)
```

На самом деле, вам не нужно определять `between`, потому что [это](http://www.quanttec.com/fparsec/reference/primitives.html#members.between) уже встроенный комбинатор FParsec.

Все это, конечно, простые примеры. Но поскольку FParsec это лишь библиотека F#, а не какой-то внешний инструмент для генерации синтаксического анализатора, нет никаких ограничений на абстракции, которые можно определять. Вы можете написать функции, которые принимают любые, необходимые вам, входные данные, делают на входных данных вычисления произвольной сложности, а затем возвращают синтаксический анализатор специального назначения или комбинатор синтаксических анализаторов.

Например, вы можете написать функцию, которая принимает шаблон регулярного выражения в качестве входных данных и возвращает `Parser` для разбора входных данных, соответствующих этому шаблону. Эта функция может использовать другой синтаксический анализатор для разбора шаблона регулярного выражения в абстрактное синтаксическое дерево, а затем компилировать абстрактное синтаксическое дерево в функцию синтаксического анализатора специального назначения. Кроме того, она может построить регулярное выражение .NET из шаблона, а затем вернуть функцию синтаксического анализатора, которая использует интерфейс прикладного программирования модуля `CharStream` библиотеки FParsec для непосредственного применения регулярного выражения к входному потоку (который является на самом деле встроенным синтаксический анализатором [`regex`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.regex) модуля `CharStream`).

Другой пример &mdash; расширяемые приложения синтаксического анализатора. При хранении функций синтаксического анализатора в словарях или других структурах данных и определении соответствующего расширенного протокола, вы можете разрешить подключаемым модулям динамически регистрировать новые синтаксические анализаторы или изменять существующие.

Возможности действительно бесконечны. Но прежде, чем вы сможете в полной мере использовать эти возможности, вам сначала необходимо ознакомиться с основами FParsec.
