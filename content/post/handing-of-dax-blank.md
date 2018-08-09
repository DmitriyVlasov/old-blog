+++
date = "2017-07-05T15:56:25+03:00"
highlight = true
math = false
tags = ["DAX","Excel","Tabular", "SQL","SQL Server","Заметка"]
title = "Сравнение обработки пустых значений в DAX, Excel и SQL"
draft = false
[header]
  caption = ""
  image = ""

+++
Пустое значение в:

* SQL это `null`;
* Excel это не заполненная ячейка;
* DAX это blank.

В DAX также существует функция [blank()]((https://msdn.microsoft.com/ru-ru/library/ee634820.aspx)) возвращающее пустое значение.

Таблица сравнения поведения пустого значения в разных окружениях

| Выражение       | DAX      | Excel    | SQL[^1] |
|-----------------|----------|----------|--------------------------------|
| blank  +  blank | blank    | 0 (ноль) | blank                          |
| blank  +  5     | 5        | 5        | blank                          |
| blank  *  5     | blank    | 0 (ноль) | blank                          |
| 5      /  blank | infinity | error    | blank                          |
| 0      /  blank | nan      | error    | blank                          |
| blank  /  blank | blank    | error    | blank                          |
| false or  blank | false    | false    | -                              |
| false and blank | false    | false    | -                              |
| true  or  blank | true     | true     | -                              |
| true  and blank | false    | true     | -                              |
| blank or  blank | blank    | error    | -                              |
| blank and blank | blank    | error    | -                              |

# Источники
* [docs.microsoft.com, Handling of Blanks, Empty Strings, and Zero Values](https://docs.microsoft.com/ru-ru/sql/analysis-services/tabular-models/data-types-supported-ssas-tabular#a-namebkmkhandblanksa-handling-of-blanks-empty-strings-and-zero-values)
* [MSDN, Функция BLANK](https://msdn.microsoft.com/ru-ru/library/ee634820.aspx)

[^1]: В SQL Server отсутствует логический тип данных. Поэтому в явном виде логические операции и таблицы истинности в SQL не применимы. Хотя в предложении `WHERE` и есть выражения `or` или `and` Которые позволяют объединять между выражения возвращающие логический контекст. 