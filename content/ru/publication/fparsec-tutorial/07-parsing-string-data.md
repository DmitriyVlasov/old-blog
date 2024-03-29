﻿+++
weight = 7

# Publication type.
publication_types = ["6"]

# Publication name and optional abbreviated version.
date = "2017-01-28"
title = "Глава 7. Синтаксический анализатор строковых данных"
publication = "Учебник библиотеки FParsec"

# Does this page contain LaTeX math? (true/false)
math = false

# Does this page require source code highlighting? (true/false)
highlight = true

# Is this a selected publication? (true/false)
selected = false

# Links (optional)
url_source = "http://www.quanttec.com/fparsec/tutorial.html#parsing-string-data"
+++

FParsec содержит различные встроенные синтаксические анализаторы для символов, строк, чисел и пробелов. В этой главе мы представим несколько синтаксических анализаторов символов и строк. Обзор всех доступных синтаксических анализаторов см. в [руководстве пользователя](http://www.quanttec.com/fparsec/reference/parser-overview.html)<sup>en</sup>.

Вы уже видели несколько применений синтаксического анализатора `pstring` (сокращенно `str` ), который просто пропускает строку определенного формата на входе. Когда синтаксический анализатор `pstring` успешно выполнился, он также возвращает пропущенную строку в качестве результата анализатора. Следующий пример демонстрирует это:

```fsharp
> test (many (str "a" <|> str "b")) "abba";;
Success: ["a"; "b"; "b"; "a"]
```

В этом примере мы так же использовали синтаксический анализатор `<|>` для объединения двух альтернативных анализаторов. Мы обсудим этот комбинатор более подробно ниже.

{{% callout note %}}
Мы говорим, что `pstring` и `pstring "a"` это «синтаксические анализаторы». Но строго говоря, `pstring` - это функция, принимающая строку и возвращающая `Parser`, но удобнее про нее говорить как (параметрический) синтаксический анализатор.
{{% /callout %}}

Когда вам не нужен результат синтаксического анализатора `pstring`, вы можете в качестве альтернативы использовать синтаксический анализатор `skipString`, который возвращает `unit` значение `()` вместо строки аргумента. В приведенном примере для производительности не имеет значения, используете ли вы `pstring` или `skipString`, так как возвращаемая строка является константой. Однако для большинства других встроенных синтаксических анализаторов и комбинаторов вы должны предпочесть варианты с префиксом в имени `skip`, когда вам не нужны значения результата синтаксического анализатора, поскольку они, как правило, будут быстрее. Если вы посмотрите обзор [библиотеки FParsec](http://www.quanttec.com/fparsec/reference/parser-overview.html)<sup>en</sup>, вы увидите варианты `skip` для многих встроенных синтаксических анализаторов и комбинаторов.

Если вы хотите проанализировать строку без учета регистра, вы можете использовать [`pstringCI`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.pstringCI)<sup>en</sup> и [`skipStringCI`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.skipStringCI)<sup>en</sup>. Например:

```fsharp
> test (skipStringCI "<float>" >>. pfloat) "<FLOAT>1.0";;
Success: 1.0
```

Часто нужно разбирать строковые переменные, чьи символы должны удовлетворять определенным критериям. Например, идентификаторы в языках программирования часто должны начинаться с буквы или подчеркивания, а затем необходимо продолжать буквы, цифры или символы подчеркивания. Чтобы проанализировать такой идентификатор, вы можете использовать следующий синтаксический анализатор:

```fsharp
let identifier =
    let isIdentifierFirstChar c = isLetter c || c = '_'
    let isIdentifierChar c = isLetter c || isDigit c || c = '_'

    many1Satisfy2L isIdentifierFirstChar isIdentifierChar "identifier"
    .>> ws // Пропускает завершающие пробелы
```

Здесь мы использовали синтаксический анализатор [`many1Satisfy2L`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.many1Satisfy2L)<sup>en</sup>, который является одним из нескольких примитивов для синтаксического анализа строк на основе предикатов символов (т.е. функций, которые принимают символ на входе и возвращают логическое значение). Он анализирует любую последовательность одного или нескольких символов (отсюда и `many1` в имени), чей первый символ удовлетворяет первой предикатной функции, а остальные символы удовлетворяют второму предикату (отсюда `Satisfy2`). Строковая метка, указанная в качестве третьего аргумента (следовательно, `L`), используется в сообщении об ошибке для описания ожидаемого ввода.

Следующие тесты показывают, как работает этот анализатор:

```fsharp
> test identifier "_";;
Success: "_"
> test identifier "_test1=";;
Success: "_test1"
> test identifier "1";;
Failure: Error in Ln: 1 Col: 1
1
^
Expecting: identifier
```
{{% callout note %}}
Если вы хотите анализировать идентификаторы на основе синтаксиса [Unicode XID](https://en.wikipedia.org/wiki/Unicode_character_property)<sup>en</sup>, рассмотрите возможность использования встроенного анализатора [`identifier`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.identifier)<sup>en</sup>.
{{% /callout %}}

Многие строковые форматы достаточно сложны, поэтому вам нужно объединить несколько примитивов символьного синтаксического анализатора и строкового синтаксического анализатора. Например, рассмотрим следующий пример анализа строки в формате РНБН:

```fsharp
  normalChar:    any char except '\' and '"'

  escapedChar:   '\\' ('\\'|'"'|'n'|'r'|'t')

  stringLiteral: '"' ( normalChar | escapedChar )* '"'
```

Прямой перевод этой грамматики в FParsec выглядит так:
```fsharp
let stringLiteral =
  let normalChar = 
    let anyCharExcept c = c <> '\\' && c <> '"'
    satisfy anyCharExcept
  let escapedChar = 
    let unescape c = 
      match c with
      | 'n' -> '\n'
      | 'r' -> '\r'
      | 't' -> '\t'
      | c   -> c
    pstring "\\" >>. (anyOf "\\nrt\"" |>> unescape)
  let quote = pstring "\"" 
  between quote quote ( manyChars (normalChar <|> escapedChar) )
```

В этом примере появилось несколько новых функций библиотеки. Давайте рассмотрим их подробнее:

- Функция [`satisfy`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.satisfy)<sup>en</sup> разбирает любой символ, который удовлетворяет заданному в параметрах предикату.
- Функция [`anyOf`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.anyOf)<sup>en</sup> разбирает любой символ, содержащийся в строке аргумента.
- Комбинатор конвейера [`|>>`](http://www.quanttec.com/fparsec/reference/primitives.html#members.:124::62::62:)<sup>en</sup> применяет функцию с правой стороны (`unescape`) к результату синтаксического анализатора с левой стороны (`anyOf "\\nrt\""`).
- Комбинатор выбора [`<|>`](http://www.quanttec.com/fparsec/reference/primitives.html#members.:60::124::62:)<sup>en</sup> применяет синтаксический анализатор с правой стороны, если синтаксический анализатор с левой стороны терпит неудачу, так что `normalChar <|> escapedChar` может анализировать как обычные, так и экранированные символы. (Мы обсудим этот комбинатор более подробно через две главы далее).
- Функция [`manyChars`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.manyChars)<sup>en</sup> анализирует последовательность символов с заданным символьным синтаксическим анализатором и возвращает его как строку.

Давайте протестируем синтаксический анализатор `stringLiteral`:
```fsharp
> test stringLiteral "\"abc\"";;
Success: "abc"
> test stringLiteral "\"abc\\\"def\\\\ghi";;
Success: "abc"def\ghi"
> test stringLiteral "\"abc\\def\"";;
Failure: Error in Ln: 1 Col: 6
"abc\def"
     ^
Expecting: any char in ‘\nrt"’
```

Вместо разбора строкового литерала посимвольно мы могли бы также разобрать его построчно:

```fsharp
let stringLiteral2 =
  let normalString = 
    let anyCharExcept c = c <> '\\' && c <> '"'
    many1Satisfy anyCharExcept
  let escapedChar = 
    let unescape c = 
      match c with
      | 'n' -> '\n'
      | 'r' -> '\r'
      | 't' -> '\t'
      | c   -> c
    pstring "\\" >>. (anyOf "\\nrt\"" |>> unescape)
  let quote = pstring "\"" 
  between quote quote ( manyStrings (normalString <|> escapedChar) )
```

Здесь мы использовали комбинатор [`manyStrings`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.manyStrings)<sup>en</sup> , который анализирует последовательность строк с заданным синтаксическим анализатором строк и возвращает объединённую строку.

{{% callout note %}}
Мы должны настроить синтаксический анализатор `normalString` что бы он требовал по крайней мере один символ, т.е. нужно использовать [`many1Satisfy`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.many1Satisfy)<sup>en</sup> вместо [`manySatisfy`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.manySatisfy)<sup>en</sup> . В противном случае `normalString` успешно выполниться, даже если нет входных данных, `escapedChar` никогда не вызовется вызываться, а [`manyStrings`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.manyStrings)<sup>en</sup> в конечном итоге вызовет исключение для предотвращения бесконечного цикла.
{{% /callout %}}

Синтаксический анализ строки с использованием оптимизированного синтаксического анализатора, такого как `many1Satisfy`, обычно немного быстрее, чем синтаксический анализ его с помощью `manyChars` и `satisfy`. В этом случае мы можем оптимизировать наш синтаксический анализатор еще немного - как только мы поймем, что два нормальных фрагмента строк должны быть разделены хотя бы одним экранированным символом:

```fsharp
let stringLiteral3 =
  let normalString = 
    let anyCharExcept c = c <> '\\' && c <> '"'
    manySatisfy anyCharExcept
  let escapedChar = 
    let unescape c = 
      match c with
      | 'n' -> '\n'
      | 'r' -> '\r'
      | 't' -> '\t'
      | c   -> c
    pstring "\\" >>. (anyOf "\\nrt\"" |>> unescape)
  let quote = pstring "\"" 
  between quote quote ( stringsSepBy normalString escapedChar) )
```

Синтаксический анализатор [`stringsSepBy`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.stringsSepBy)<sup>en</sup> анализирует последовательность строк (первый аргумент), разделенных другими строками (второй аргумент). Он возвращает все разобранные строки, включая строки разделителя, в виде новой объединённой строки.

Обратите внимание, что `stringLiteral3` использует [`manySatisfy`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.many1Satisfy)<sup>en</sup> вместо [`many1Satisfy`](http://www.quanttec.com/fparsec/reference/charparsers.html#members.many1Satisfy)<sup>en</sup> в своем определении `normalString`, так что он может анализировать экранированные символы, которые не разделены обычными символами. Это приведет к бесконечному циклу, потому что `escapedChar` не будет исполнено при отсутствии входных данных.