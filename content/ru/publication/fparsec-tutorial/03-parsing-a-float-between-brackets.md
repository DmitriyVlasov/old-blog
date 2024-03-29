+++
weight = 3

# Publication type.
publication_types = ["6"]

# Publication name and optional abbreviated version.
date = "2017-01-28"
title = "Глава 3. Синтаксический анализатор числа с плавающей точкой в скобках"
publication = "Учебник библиотеки FParsec"

# Does this page contain LaTeX math? (true/false)
math = false

# Does this page require source code highlighting? (true/false)
highlight = true

# Is this a selected publication? (true/false)
selected = false

# Links (optional)
url_source = "http://www.quanttec.com/fparsec/tutorial.html#parsing-a-float-between-brackets"
+++

Реализация синтаксических анализаторов с использованием библиотеки FParsec обычно означает, что высокоуровневые синтаксические анализаторы получены как комбинация низкоуровневых анализаторов. Вы начинаете с анализатора примитивов, предоставляемых библиотекой, а затем последовательно объединяете их в анализаторы более высокого уровня, пока вы, наконец, не имеете один синтаксический анализатор для полной обработки входных данных.

В следующих главах мы продемонстрируем этот подход, обсуждая различные варианты примеров синтаксических анализаторов, которые построены друг из друга. В этой главе мы начнем с очень простого анализатора для числа с плавающей точкой в скобках:

```fsharp
let str s = pstring s
let floatBetweenBrackets = str "[" >>. pfloat .>> str "]"
```
{{% callout note %}}
Если вы пытаетесь скомпилировать этот или другой фрагмент кода, и вы получаете ошибку компилятора F# "value restriction", пожалуйста посмотрите [главу 10 Ограничение значений F#](../10-fsharps-value-restriction)
{{% /callout %}}

Определение `str` и `floatBetweenBrackets` включает в себя три библиотечные функции, которые мы ранее не рассматривали: [`pstring`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.pstring), [`>>.`](http://www.quanttec.com/fparsec/reference/primitives.html#members.:62::62:..) и [`>>.`](http://www.quanttec.com/fparsec/reference/primitives.html#members...:62::62:).

Функция 
```fsharp
val pstring: string -> Parser<string,'u>
```
принимает строку в качестве аргумента и возвращает синтаксический анализатор для этой строки. Когда анализатор применяется к входному потоку он проверяет соответствуют ли символы во входном потоке строке, заданной в аргументе. Если символы полностью совпадают со строкой, анализатор поглощает их, то есть пропускает и идет дальше. В противном случае он не исполнится и не поглотит входные данные. Когда анализатор успешно обрабатывает, он также возвращает данную строку в качестве результата анализатора, но, поскольку строка константа, вы будете редко использовать этот результат.

Функция `pstring` не называется `string`, потому что иначе она скроет встроенную в F# функцию `string`. Как правило, имена синтаксических анализаторов в FParsec, которые конфликтуют со встроенными именами функций в F#, имеют префикс &mdash; символ `р`. Функция [`pfloat`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.pfloat) еще один пример этого соглашения об именовании.

Для экономии нескольких нажатий клавиш, мы сокращаем `pstring` как `str`. Так, например, `str "["` это синтаксический анализатор, который пропускает символ `'['`.

Бинарные операторы  `>>.` и  `.>>` имеет следующие типы:
```fsharp
val (>>.): Parser<'a,'u> -> Parser<'b,'u> -> Parser<'b,'u>
val (.>>): Parser<'a,'u> -> Parser<'b,'u> -> Parser<'a,'u>
```

Как вы можете видеть из этих сигнатур, оба оператора являются комбинаторами синтаксических анализаторов, которые строят новый анализатор из двух аргументов &mdash; синтаксических анализаторов. Синтаксический анализатор `p1 >>. p2` разбирает `p1` и `p2` последовательно и возвращает результат `p2`. Синтаксический анализатор `p1 .>> p2` также разбирает `p1` и `p2` последовательно, но возвращает результат `p1` вместо `p2`. В каждом случае точка указывает на сторону синтаксического анализатора, результат которого возвращается. Объединив оба оператора в `p1 >>. р2 .>> p3` мы получим синтаксический анализатор, который разбирает `p1`, `p2` и `p3` последовательно и возвращает результат `p2`.

{{% callout note %}}
Касательно несколько неточной формулировки "разбирает `p1` и `p2` последовательно" мы на самом деле имели в виду: синтаксический анализатор `p1` применяется к входным данным, и если `p1` успешно исполнен, то `p2` применяется к остальной части входных данных. В случае если любой из двух элементов синтаксического анализатора не исполнился, совокупный синтаксический анализатор сразу передает сообщение об ошибке.

В документации библиотеки FParsec мы часто используем такие выражения, как "синтаксический анализ `p`" или "синтаксический анализ вхождения `p`". Вместо этого технически более точным "применяется синтаксический анализатор `p` к остатку входных данных и если `p` успешно исполнен...", надеясь, что точное значение очевидно из контекста.
{{% /callout %}}

Следующие тесты показывают, что `floatBetweenBrackets` разбирает правильные входные данные, как и ожидалось, и дает информативные сообщения об ошибках, когда он сталкивается с неправильными входными данными:
```fsharp
> test floatBetweenBrackets "[1.0]";;
Success: 1.0

> test floatBetweenBrackets "[]";;
Failure: Error in Ln: 1 Col: 2
[]
 ^
Expecting: floating-point number

> test floatBetweenBrackets "[1.0";;
Failure: Error in Ln: 1 Col: 5
[1.0
    ^
Note: The error occurred at the end of the input stream.
Expecting: ']'
```
{{% callout note %}}
* Обратите внимание, что все инфиксные F# операторы, которые начинаются с `<` или `>` (ведущие символы `.` игнорируются) являются левоассоциативными. 
* Следовательно, `p1 >>. р2 .>> p3` эквивалентно `(p1 >>. p2) .>> p3`.
* Тем не менее, в этом случае ассоциативность не имеет никакого влияния на совокупное поведение синтаксического анализатора.
{{% /callout %}}
